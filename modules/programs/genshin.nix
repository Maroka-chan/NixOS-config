{ pkgs, lib, config, username, inputs, ... }:
with lib;
let
  module_name = "genshin";
  cfg = config.configured.programs."${module_name}";
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable Genshin Impact";
    persist = mkEnableOption "Persist state";
    hdr = {
      enable = mkEnableOption "Enable SDR -> HDR tonemapping";
    };
    mangohud.enable = "Enable MangoHUD";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # Block telemetry
      networking.hosts = {
        "0.0.0.0" = [ "overseauspider.yuanshen.com" "log-upload-os.hoyoverse.com" "log-upload-os.mihoyo.com" "dump.gamesafe.qq.com" "log-upload.mihoyo.com" "devlog-upload.mihoyo.com" "uspider.yuanshen.com" "sg-public-data-api.hoyoverse.com" "public-data-api.mihoyo.com" "prd-lender.cdp.internal.unity3d.com" "thind-prd-knob.data.ie.unity3d.com" "thind-gke-usc.prd.data.corp.unity3d.com" "cdp.cloud.unity3d.com" "remote-config-proxy-prd.uca.cloud.unity3d.com" "pc.crashsight.wetest.net" ];
      };

      security.wrappers = mkIf cfg.hdr.enable {
        gamescope = {
          owner = "root";
          group = "root";
          source = "${pkgs.gamescope}/bin/gamescope";
          capabilities = "cap_sys_nice+pie";
        };
        umu-run = {
          owner = "root";
          group = "root";
          source = "${inputs.umu.packages.${pkgs.system}.umu}/bin/umu-run";
          setuid = true;
        };
      };

      environment.systemPackages = let
        fps_unlocker = pkgs.fetchurl {
          url = "https://codeberg.org/mkrsym1/fpsunlock/releases/download/v1.2.0/fpsunlock.exe";
          hash = "sha256-KMEXjVwSgMjwPP6pM6UZgeHb9Ot2oiw5Vjm1q+4K0Dw=";
        };
        start_batch = pkgs.writeTextFile {
          name = "genshin_launch.bat";
          text = ''
            start "" "Z:\home\${username}\.umu\hoyoplay\drive_c\Program Files\HoYoPlay\games\Genshin Impact game\GenshinImpact.exe"
            start "" "Z:\nix\store\${builtins.baseNameOf fps_unlocker}" 240 5000
          '';
        };
        # Launching the batch script with VBScript like this prevents a terminal pop up
        vbs_launch = pkgs.writeTextFile {
          name = "genshin_launch_no_terminal.vbs";
          text = ''
            CreateObject("Wscript.Shell").Run "${start_batch}", 0, True
          '';
        };
      in [
        (pkgs.makeDesktopItem {
          name = "Genshin Impact";
          desktopName = "Genshin Impact";
          icon = ./. + "/genshin.ico";
          exec = let
            launch-script = pkgs.writeShellApplication {
              name = module_name;
              runtimeInputs = [ inputs.umu.packages.${pkgs.system}.umu ] ++ optionals cfg.mangohud.enable [ pkgs.mangohud ];
              text = ''
                # AMD_VULKAN_ICD fixes global illumination
                # see https://github.com/an-anime-team/an-anime-game-launcher/issues/397
                export XCURSOR_SIZE=${toString config.home-manager.users.${username}.home.pointerCursor.size}
                WINEPREFIX=$HOME/.umu/hoyoplay GAMEID=${module_name} AMD_VULKAN_ICD=RADV${optionalString cfg.mangohud.enable " mangohud"} umu-run "${vbs_launch}"
              '';
            };
          in "${launch-script}/bin/${module_name}";
          categories = [ "Game" ];
        })
      ] ++ optionals cfg.hdr.enable [
        (pkgs.writeShellApplication {
          name = "genshin-hdr";
          runtimeInputs = [] ++ optionals cfg.mangohud.enable [ pkgs.mangohud ];
          text = ''
            # AMD_VULKAN_ICD fixes global illumination
            # see https://github.com/an-anime-team/an-anime-game-launcher/issues/397
            export XCURSOR_SIZE=${toString config.home-manager.users.${username}.home.pointerCursor.size}
            WINEPREFIX=$HOME/.umu/hoyoplay GAMEID=${module_name} AMD_VULKAN_ICD=RADV GAMESCOPE_WAYLAND_DISPLAY=:gamescope-0 /run/wrappers/bin/gamescope -O DP-3 -f -r 240 --hdr-enabled --hdr-itm-enable --hdr-itm-target-nits=500 --hdr-sdr-content-nits=500 -W 2560 -H 1440 -w 2560 -h 1440 --rt --immediate-flips --adaptive-sync --generate-drm-mode=cvt${optionalString cfg.mangohud.enable " --mangoapp"} --sdr-gamut-wideness=0.5 -- /run/wrappers/bin/umu-run "${start_batch}"
          '';
        })
      ];
    })
    (mkIf cfg.persist {
      environment.persistence."/persist" = {
        users.${username} = {
          directories = [
            ".umu/hoyoplay"
            ".local/share/umu"
            ".local/share/Steam/compatibilitytools.d"
          ];
        };
      };
    })
  ];
}


