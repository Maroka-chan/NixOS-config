{ config, pkgs, lib, ... }:
{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  systemd.services."netns@" = {
    description = "%I network namespace";
    before = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute2}/bin/ip netns add %I";
      ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
    };
  };

  systemd.services.wg = {
    description = "wg network interface";
    bindsTo = [ "netns@wg.service" ];
    requires = [ "network-online.target" ];
    after = [ "netns@wg.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = with pkgs; writers.writeBash "wg-up" ''
        set -e
        ${iproute2}/bin/ip link add wg0 type wireguard
        ${iproute2}/bin/ip link set wg0 netns wg
        ${iproute2}/bin/ip -n wg address add 10.67.170.174/32 dev wg0
        ${iproute2}/bin/ip -n wg -6 address add fc00:bbbb:bbbb:bb01::4:aaad/128 dev wg0
        ${iproute2}/bin/ip netns exec wg \
          ${wireguard-tools}/bin/wg setconf wg0 /etc/wireguard/mullvadvpn.conf
        ${iproute2}/bin/ip -n wg link set wg0 up
        ${iproute2}/bin/ip -n wg link set dev lo up # Start the loopback interface
        ${iproute2}/bin/ip -n wg route add default dev wg0
        ${iproute2}/bin/ip -n wg -6 route add default dev wg0

        # Create a bridge
        ${iproute2}/bin/ip link add v-net-0 type bridge
        ${iproute2}/bin/ip addr add 192.168.15.5/24 dev v-net-0
        ${iproute2}/bin/ip link set dev v-net-0 up

        # Set up veth pair to link namespace with host network
        ${iproute2}/bin/ip link add veth-vpn-br type veth peer name veth-vpn netns wg
        ${iproute2}/bin/ip link set veth-vpn-br master v-net-0

        ${iproute2}/bin/ip -n wg addr add 192.168.15.1/24 dev veth-vpn
        ${iproute2}/bin/ip -n wg link set dev veth-vpn up

        # Add routes
        ${iproute2}/bin/ip -n wg route add 10.0.2.0/24 via 192.168.15.5 # Makes services reachable from outside
        # Route incoming packets for port 9091 to the namespace
        ${iptables}/bin/iptables -t nat -A PREROUTING -p tcp --dport 9091 -j DNAT --to-destination 192.168.15.1:9091
        #iptables -t nat -A POSTROUTING -s 192.168.15.0/24 -j MASQUERADE
      '';
      ExecStop = with pkgs; writers.writeBash "wg-down" ''
        ${iproute2}/bin/ip -n wg route del default dev wg0
        ${iproute2}/bin/ip -n wg -6 route del default dev wg0
        ${iproute2}/bin/ip -n wg link del wg0
        ${iproute2}/bin/ip -n wg link del v-net-0
        ${iproute2}/bin/ip -n wg link del veth-vpn

        ${iptables}/bin/iptables -t nat -D PREROUTING -p tcp --dport 9091 -j DNAT --to-destination 192.168.15.1:9091
      '';
    };
  };

  systemd.services.transmission = {
    bindsTo = [ "netns@wg.service" ];
    after = [ "netns@wg.service" ];
    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/wg";
    };
  };

  services.transmission = {
    enable = true;
    openRPCPort = true;
    settings = {
      "bind-address-ipv4" = "10.67.170.174";
      "rpc-bind-address" = "0.0.0.0";
      "rpc-whitelist-enabled" = false;
    };
  };
}
