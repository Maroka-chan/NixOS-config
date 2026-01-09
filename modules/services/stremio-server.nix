{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  module_name = "stremio-server";
  cfg = config.services."${module_name}";
  inherit (lib) mkEnableOption mkIf;
in {
  options.services."${module_name}" = {
    enable = mkEnableOption "Enable the Stremio streaming server";
    openFirewall = mkEnableOption "Opens default ports used by stremio";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [
      11470
      12470
    ];

    systemd.tmpfiles.settings.stremioServerDirs = {
      "/var/lib/stremio-server"."d".mode = "700";
      "/var/lib/stremio-server/.stremio-server"."d".mode = "700";
    };

    systemd.services.stremio-server = {
      description = "Stremio Streaming Server";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        ExecStart = let
          serverjs = pkgs.fetchurl {
            url = "https://dl.strem.io/server/v4.20.12/desktop/server.js";
            hash = "sha256-pSfz3SDG57Nesgd868+FnLqBQGAvJvEPjonDwaCOrBM=";
          };
          pkgs_old = inputs.nixpkgs-stremio-server;
          jellyfin-ffmpeg = pkgs_old.legacyPackages.${pkgs.system}.jellyfin-ffmpeg;
          node_14 = pkgs_old.legacyPackages.${pkgs.system}.nodejs-14_x;
          launch_stremio = pkgs.writeShellApplication {
            name = "launch-stremio-server";
            runtimeInputs = [
              jellyfin-ffmpeg
              node_14
              pkgs.ps
            ];
            text = ''
              HOME=/var/lib/stremio-server node ${serverjs}
            '';
          };
        in "${launch_stremio}/bin/launch-stremio-server";
        Restart = "on-failure";
        TimeoutSec = 15;
        WorkingDirectory = "/var/lib/stremio-server";
      };
    };
  };
}
