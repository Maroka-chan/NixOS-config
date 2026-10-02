{
  config,
  pkgs,
  lib,
  username,
  useImpermanence,
  extraConfig,
  wallpaper,
  githubUsername,
  avatarHash,
  inputs,
  ...
}: let
  homeDirectory = "/home/${username}";
  inherit (lib) mkMerge mkIf;
in
  mkMerge [
    {
      home = {inherit username homeDirectory;};
      home.packages = with pkgs; [
        # Clipboard utilities
        # Needed to make Vim use global clipboard
        wl-clipboard

        pavucontrol # Audio control gui
        imv # Image Viewer
        mpv # Media Player
        sioyek # Document Viewer
        gpu-screen-recorder # Screen recorder

        (makeDesktopItem {
          name = "ProtonMail";
          desktopName = "ProtonMail";
          icon = ./. + "/protonmail.ico";
          exec = "${pkgs.brave}/bin/brave --user-data-dir=${homeDirectory}/.config/chromium-mail --app=https://mail.proton.me";
        })

        (makeDesktopItem {
          name = "Linear";
          desktopName = "Linear";
          icon = ./. + "/linear.svg";
          exec = "${pkgs.brave}/bin/brave --user-data-dir=${homeDirectory}/.config/chromium-linear --app=https://linear.app";
        })
      ];

      # Terminal Emulator
      programs.foot.enable = true;
      programs.foot.settings = {
        main = {
          font = "monospace:size=11";
          dpi-aware = "yes";
        };
        colors-dark = {
          alpha = 0.9;

          # Kanagawa Dragon
          foreground = "c5c9c5";
          background = "181616";

          selection-foreground = "C8C093";
          selection-background = "2D4F67";

          regular0 = "0d0c0c";
          regular1 = "c4746e";
          regular2 = "8a9a7b";
          regular3 = "c4b28a";
          regular4 = "8ba4b0";
          regular5 = "a292a3";
          regular6 = "8ea4a2";
          regular7 = "C8C093";

          bright0 = "a6a69c";
          bright1 = "E46876";
          bright2 = "87a987";
          bright3 = "E6C384";
          bright4 = "7FB4CA";
          bright5 = "938AA9";
          bright6 = "7AA89F";
          bright7 = "c5c9c5";

          "16" = "b6927b";
          "17" = "b98d7b";
        };
      };

      # GPG & Password Store
      programs.password-store.enable = true;
      programs.password-store.settings = {PASSWORD_STORE_DIR = "$XDG_DATA_HOME/password-store";};
      programs.gpg.enable = true;
      services.pass-secret-service.enable = true;
      services.gpg-agent = {
        enable = true;
        enableZshIntegration = true;
        pinentry.package = pkgs.pinentry-gtk2;
        extraConfig = ''
          allow-preset-passphrase
        '';
      };

      gtk = {
        enable = true;
        gtk4.theme = config.gtk.theme;
        theme = {
          package = pkgs.dracula-theme;
          name = "Dracula";
        };
        iconTheme = {
          package = pkgs.dracula-icon-theme;
          name = "Dracula";
        };
      };

      home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
      };

      #xdg.configFile."niri/config.kdl".source = pkgs.runCommandNoCCLocal "niri-config" { } ''
      #  cp ${./config.kdl} $out
      #  substituteInPlace $out \
      #    --replace-fail "\''${pkgs.swaybg}" "${pkgs.swaybg}/bin/swaybg" \
      #    --replace-fail "\''${wallpaper}" "${../../../dotfiles/wallpapers/miku_nakano.png}"
      #'';

      xdg.configFile."niri/config.kdl".source = pkgs.runCommandLocal "niri-config" {} ''
        cp ${./config.kdl} $out

        chmod +w $out

        cat <<'EOF' >> $out
        ${extraConfig}
        EOF
      '';

      #xdg.configFile."niri/config.kdl".source = ./config.kdl;

      # Noctalia v5 - written to ~/.config/noctalia/config.toml.
      # GUI changes are stored separately in ~/.local/state/noctalia/settings.toml
      # and take precedence over these values.
      programs.noctalia = {
        enable = true;
        settings = {
          bar = {
            default = {
              concave_edge_corners = false;
              shadow = false;
              start = ["control-center" "tray" "privacy" "screen_recorder"];
              center = ["workspaces"];
              end = ["network" "bluetooth" "volume" "notifications" "battery" "clock"];
            };
          };

          widget = {
            control-center = {
              # v5 has no distro-logo option; use the NixOS snowflake instead.
              custom_image = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
              custom_image_colorize = true;
            };
            privacy.hide_inactive = true;
            screen_recorder.type = "noctalia/screen_recorder:recorder";
            workspaces.show_labels = false;
            # Replaces the network-manager-vpn plugin.
            network.vpn_status = "both";
          };

          plugins = {
            # Declaring any source replaces the built-in git sources (official/community),
            # so plugins only come from the flake-pinned, read-only store path.
            source = [
              {
                name = "nix-official";
                kind = "path";
                location = "${inputs.noctalia-plugins}";
                enabled = true;
              }
            ];
            auto_update = "none";
            enabled = ["noctalia/screen_recorder"];
          };
          plugin_settings."noctalia/screen_recorder" = {
            video_source = "portal";
            hide_inactive = false;
          };

          battery.warning_threshold = 20;
          dock.enabled = false;

          theme = {
            mode = "dark";
            source = "wallpaper";
            wallpaper_scheme = "m3-rainbow";
          };

          shell = {
            avatar_path = lib.mkIf (lib.hasAttrByPath ["user" "name"] config.programs.git.settings) "${
              pkgs.lib.fetchGHUrl {
                gh_username = githubUsername;
                hash = avatarHash;
              }
            }";
            telemetry_enabled = false;
            popup_shadows = false;
            panel.shadow = false;
          };

          lockscreen.fingerprint = true;

          location.address = "Copenhagen, Denmark";

          wallpaper = {
            enabled = true;
            directory = "${../../../dotfiles/wallpapers}";
            default.path = "${wallpaper}";
          };

          nightlight.enabled = true;
        };
      };
    }

    (mkIf useImpermanence {
      home.persistence."/persist" = {
        files = [
          ".pam-gnupg"
          ".config/nix/nix.conf"
        ];
        directories = [
          "Downloads"
          "Documents"
          "Pictures"
          "Videos"
          "Music"
          ".ssh"
          ".zplug"
          ".local/state/wireplumber"
          ".local/share/password-store"
          ".config/chromium-mail"
          ".config/chromium-linear"
          # Noctalia GUI overrides, UI state, plugin caches and plugin settings
          ".local/state/noctalia"
          ".logseq"
        ];
      };
    })
  ]
