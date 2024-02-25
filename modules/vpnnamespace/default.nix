{ lib, pkgs, config, ... }: # NOTE TO SELF: Make it so you can make multiple namespaces by giving a list of objects with settings as attributes. Also add an option to enable whether the namespace should use a vpn or not.
with lib;
let
  cfg = config.services.vpnnamespace;
in {
  options.services.vpnnamespace = {
    enable = mkEnableOption (lib.mdDoc "VPN Namespace") // {
      description = lib.mdDoc ''
        Whether to enable the VPN namespace.

        To access the namespace a veth pair is used to
        connect the vpn namespace and the default namespace
        through a linux bridge. One end of the pair is
        connected to the linux bridge on the default namespace.
        The other end is connected to the vpn namespace.

        Systemd services can be run within the namespace by
        adding these options:

        bindsTo = [ "netns@wg.service" ];
        requires = [ "network-online.target" ];
        after = [ "wg.service" ];
        serviceConfig = {
          NetworkNamespacePath = "/var/run/netns/wg";
        };
      '';
    };

    accessibleFrom = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = lib.mdDoc ''
        Subnets or specific addresses that the namespace should be accessible to.
      '';
      example = [
        "10.0.2.0/24"
        "192.168.1.27"
      ];
    };

    namespaceAddress = mkOption {
      type = types.str;
      default = "192.168.15.1";
      description = lib.mdDoc ''
        The address of the veth interface connected to the vpn namespace.
        
        This is the address used to reach the vpn namespace from other
        namespaces connected to the linux bridge.
      '';
    };

    bridgeAddress = mkOption {
      type = types.str;
      default = "192.168.15.5";
      description = lib.mdDoc ''
        The address of the linux bridge on the default namespace.

        The linux bridge sits on the default namespace and
        needs an address to make communication between the
        default namespace and other namespaces on the
        bridge possible.
      '';
    };

    wireguardAddressPath = mkOption {
      type = types.path;
      default = "";
      description = lib.mdDoc ''
        The address for the wireguard interface.
        It is a path to a file containing the address.
        This is done so the whole wireguard config can be specified
        in a secret file, such as a yaml file for sops-nix.
      '';
    };

    wireguardConfigFile = mkOption {
      type = types.path;
      default = "/etc/wireguard/wg0.conf";
      description = lib.mdDoc ''
        Path to the wireguard config to use.
        
        Note that this is not a wg-quick config.
      '';
    };

    portMappings = mkOption {
      type = with types; listOf (attrsOf port);
      default = [];
      description = lib.mdDoc ''
        A list of pairs mapping a port from the host to a port in the namespace.
      '';
      example = [{
        From = 80;
        To = 80;
      }];
    };
  };

  config = mkIf cfg.enable {
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
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = with pkgs; writers.writeBash "wg-up" (''
          set -e

          # Set up the wireguard interface
          ${iproute2}/bin/ip link add wg0 type wireguard
          ${iproute2}/bin/ip link set wg0 netns wg
          ${iproute2}/bin/ip -n wg address add $(cat ${cfg.wireguardAddressPath}) dev wg0
          ${iproute2}/bin/ip netns exec wg \
            ${wireguard-tools}/bin/wg setconf wg0 ${cfg.wireguardConfigFile}
          ${iproute2}/bin/ip -n wg link set wg0 up
          ${iproute2}/bin/ip -n wg route add default dev wg0

          # Start the loopback interface
          ${iproute2}/bin/ip -n wg link set dev lo up

          # Create a bridge
          ${iproute2}/bin/ip link add v-net-0 type bridge
          ${iproute2}/bin/ip addr add ${cfg.bridgeAddress}/24 dev v-net-0
          ${iproute2}/bin/ip link set dev v-net-0 up

          # Set up veth pair to link namespace with host network
          ${iproute2}/bin/ip link add veth-vpn-br type veth peer name veth-vpn netns wg
          ${iproute2}/bin/ip link set veth-vpn-br master v-net-0

          ${iproute2}/bin/ip -n wg addr add ${cfg.namespaceAddress}/24 dev veth-vpn
          ${iproute2}/bin/ip -n wg link set dev veth-vpn up
        ''

        # Add routes to make the namespace accessible
        + strings.concatMapStrings (x: "${iproute2}/bin/ip -n wg route add ${x} via ${cfg.bridgeAddress}" + "\n") cfg.accessibleFrom

        # Add prerouting rules
        + strings.concatMapStrings (x: "${iptables}/bin/iptables -t nat -A PREROUTING -p tcp --dport ${builtins.toString x.From} -j DNAT --to-destination ${cfg.namespaceAddress}:${builtins.toString x.To}" + "\n") cfg.portMappings);


        ExecStopPost = with pkgs; writers.writeBash "wg-down" (''
          ${iproute2}/bin/ip -n wg route del default dev wg0
          ${iproute2}/bin/ip -n wg link del wg0
          ${iproute2}/bin/ip -n wg link del veth-vpn
          ${iproute2}/bin/ip link del v-net-0
        ''

        # Delete prerouting rules
        + strings.concatMapStrings (x: "${iptables}/bin/iptables -t nat -D PREROUTING -p tcp --dport ${builtins.toString x.From} -j DNAT --to-destination ${cfg.namespaceAddress}:${builtins.toString x.To}" + "\n") cfg.portMappings);
      };
    };
  };
}
