{ pkgs, ... }:
let
  user = "jellyfin";
  group = "jellyfin";
  service_name = "jellyfin-podman";
  compose_file = ./. + "/docker-compose.yml";
  docker_compose = "${pkgs.podman-compose}/bin/podman-compose -f ${compose_file}";
in {
  systemd.services."${service_name}" = {
    path = [ "/run/wrappers" pkgs.podman ];
    serviceConfig = {
      User = user;
      Group = group;
      Type = "forking";
      Restart = "on-failure";
      TimeoutStopSec = 70;
    };
    script = "${docker_compose} up -d";
    preStop = "${docker_compose} down";

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
    allowedTCPPorts = [ 8096 8920 ];
  };
}