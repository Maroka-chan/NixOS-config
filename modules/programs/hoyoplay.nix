{ pkgs, lib, config, username, inputs, ... }:
with lib;
let
  module_name = "hoyoplay";
  cfg = config.configured.programs."${module_name}";
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable HoYoPlay";
    persist = mkEnableOption "Persist state";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # Block telemetry
      networking.hosts = {
        "0.0.0.0" = [ "overseauspider.yuanshen.com" "log-upload-os.hoyoverse.com" "log-upload-os.mihoyo.com" "dump.gamesafe.qq.com" "log-upload.mihoyo.com" "devlog-upload.mihoyo.com" "uspider.yuanshen.com" "sg-public-data-api.hoyoverse.com" "public-data-api.mihoyo.com" "prd-lender.cdp.internal.unity3d.com" "thind-prd-knob.data.ie.unity3d.com" "thind-gke-usc.prd.data.corp.unity3d.com" "cdp.cloud.unity3d.com" "remote-config-proxy-prd.uca.cloud.unity3d.com" "pc.crashsight.wetest.net" ];
      };

      environment.systemPackages = let
        hoyoplay-version = "1.0.5.88";
        hoyoplay = pkgs.fetchurl {
          url = "https://hoyo.link/8HbjFBAL";
          hash = "sha256-EOXyqnGxA7gQ6be9671VIhyYQVElIKXKieRskzZ8Dhw=";
        };
        hoyoplay-script = pkgs.writeShellApplication {
          name = module_name;
          runtimeInputs = [
            pkgs.p7zip
            inputs.umu.packages.${pkgs.system}.umu
          ];
          text = let
            hoyoplay_path = "$HOME/.umu/hoyoplay/drive_c/Program Files/HoYoPlay";
          in ''
            if [ ! -f "${hoyoplay_path}/launcher.exe" ]; then
              mkdir -p "${hoyoplay_path}"
              7z x "${hoyoplay}" -o"${hoyoplay_path}"
              mv "${hoyoplay_path}/${hoyoplay-version}/launcher.exe" "${hoyoplay_path}"
            fi

            export XCURSOR_SIZE=${toString config.home-manager.users.${username}.home.pointerCursor.size}
            WINEPREFIX=$HOME/.umu/hoyoplay GAMEID=${module_name} umu-run "${hoyoplay_path}/launcher.exe"
          '';
        };
      in [
        (pkgs.makeDesktopItem {
          name = "HoYoPlay";
          desktopName = "HoYoPlay";
          icon = ./. + "/hoyoplay.ico";
          exec = "${hoyoplay-script}/bin/${module_name}";
          categories = [ "Game" ];
        })
        (pkgs.makeDesktopItem {
          name = "Zenless Zone Zero";
          desktopName = "Zenless Zone Zero";
          icon = ./. + "/zzz.ico";
          exec = let
            launch = pkgs.writeShellApplication {
              name = module_name;
              runtimeInputs = [
                inputs.umu.packages.${pkgs.system}.umu
              ];
              text = let
                zzz_path = "$HOME/.umu/hoyoplay/drive_c/Program Files/HoYoPlay/games/ZenlessZoneZero Game";
              in ''
                if [ ! -f "${zzz_path}/ZenlessZoneZero.exe" ]; then
                  "${hoyoplay-script}/bin/${module_name}"
                  exit 0
                fi

                export XCURSOR_SIZE=${toString config.home-manager.users.${username}.home.pointerCursor.size}
                WINEPREFIX=$HOME/.umu/hoyoplay GAMEID=${module_name} umu-run "${zzz_path}/ZenlessZoneZero.exe"
              '';
            };
          in "${launch}/bin/${module_name}";
          categories = [ "Game" ];
        })
      ];
    })
    (mkIf cfg.persist {
      environment.persistence."/persist" = {
        users.${username} = {
          directories = [
            ".umu/${module_name}"
            ".local/share/umu"
          ];
        };
      };
    })
  ];
}

