{ pkgs, ... }:
let
  user = "transmission";
  group = "transmission";
  container = "transmission";
  user_pass = builtins.readFile "/run/keys/transmission-pass.secret";
in {
  # deployment.keys."transmission-pass.secret" = {
  #   keyCommand = [ "pass" "akebi/service/transmission/user_pass" ];
  # };

  systemd.services."${container}-podman" = {
    path = [ "/run/wrappers" ];
    serviceConfig = {
      User = user;
      Group = group;
      Type = "forking";
      Restart = "on-failure";
      TimeoutStopSec = 70;
    };
    script = ''${pkgs.podman}/bin/podman run \
          --name ${container} \
          --rm \
          --replace \
          --label io.containers.autoupdate=registry \
          --network=container:gluetun \
          \
          --volume=transmission_config:/config \
          --volume=transmission_watch:/watch \
          --volume=transmission_downloads:/downloads \
          \
          --env USER="admin" \
          --env PASS="${user_pass}" \
          \
          -d ghcr.io/linuxserver/transmission:latest'';

    preStop = "${pkgs.podman}/bin/podman stop ${container}";

    after = [ "network-online.target" ];
    wantedBy = [ "network-online.target" ];
  };

  systemd.services."gluetun-podman" = {
    path = [ "/run/wrappers" ];
    serviceConfig = {
      User = user;
      Group = group;
      Type = "forking";
      Restart = "on-failure";
      TimeoutStopSec = 70;
    };
    script = ''${pkgs.podman}/bin/podman run \
          --name gluetun \
          --rm \
          --replace \
          --cap-add=NET_ADMIN \
          --label io.containers.autoupdate=registry \
          \
          --publish=9091:9091/tcp \
          --publish=60955:60955/tcp \
          --publish=60955:60955/udp \
          \
          --volume=gluetun:/gluetun \
          --volume=/dev/net/tun:/dev/net/tun \
          \
          --env VPNSP="mullvad" \
          --env VPN_TYPE="wireguard" \
          --env CITY="Frankfurt" \
          --env WIREGUARD_PRIVATE_KEY="YFqPjsjQGuEqipN4dcG+41pB168V8gTfIDD2mx2RlFA=" \
          --env WIREGUARD_ADDRESS="10.64.24.119/32" \
          --env DNS_ADDRESS="100.64.0.23" \
          --env WIREGUARD_ENDPOINT_PORT="51820" \
          --env BLOCK_SURVEILLANCE="on" \
          --env BLOCK_MALICIOUS="on" \
          --env BLOCK_ADS="on" \
          --env FIREWALL_VPN_INPUT_PORTS="60955" \
          \
          -d ghcr.io/qdm12/gluetun:latest'';

    preStop = "${pkgs.podman}/bin/podman stop ${container}";

    after = [ "network-online.target" ];
    wantedBy = [ "network-online.target" ];
  };
  
  users = {
    groups.${group} = {};
    users.${user} = {
      isNormalUser = true;
      group = group;
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      9091 60955  # transmission
      51820       # wireguard
      ];
    allowedUDPPorts = [
      60955       # transmission
      ];
  };
}