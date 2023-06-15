{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.jellyfin;
  user = "jellyfin";
  group = "jellyfin";
  container = "jellyfin";
  service_name = "${container}-podman";
in {
  options.services."${service_name}" = {
    enable = mkEnableOption "Jellyfin service";
    port = mkOption {
      type = types.int;
      default = 8096;
      description = "Port to expose Jellyfin on";
    };
    media_path = mkOption {
      type = types.str;
      default = "/data";
      description = "Directory to mount as media";
    };
    config_path = mkOption {
      type = types.str;
      default = "/config";
      description = "Directory to mount as config";
    };
  };

  config = mkIf cfg.enable {
    systemd.services."${service_name}" = {
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
                \
                --volume=jellyfin_data:/data:ro \
                --volume=jellyfin_config:/config \
                \
                --publish=8096:8096/tcp \
                --publish=8920:8920/tcp \
                \
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
  };
}