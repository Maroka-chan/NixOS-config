{ pkgs, ... }:
let
  user = "jellyfin";
  group = "jellyfin";
  container = "jellyfin-podman";
in {
  systemd.services.${container} = {
    path = [ "/run/wrappers" ];
    serviceConfig = {
      User = user;
      Group = group;
      Type = "forking";
      Restart = "on-failure";
      TimeoutStopSec = 70;
    };
    script = ''${pkgs.podman}/bin/podman run \
          --rm \
          --name ${container} \
          --label io.containers.autoupdate=registry \
          --replace \
          --publish=8096:8096/tcp \
          --publish=8920:8920/tcp \
          -d ghcr.io/linuxserver/jellyfin:latest'';
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
    allowedTCPPorts = [ 8096 8920 ];
  };
}