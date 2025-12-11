{
  config,
  pkgs,
  lib,
  username,
  useImpermanence,
  extraConfig,
  wallpaper,
  avatarHash,
  ...
}:
let
  homeDirectory = "/home/${username}";
  inherit (lib) mkMerge mkIf;
in
mkMerge [
  {
    home = { inherit username homeDirectory; };
    home.packages = with pkgs; [
      # Clipboard utilities
      # Needed to make Vim use global clipboard
      wl-clipboard

      pavucontrol # Audio control gui
      imv # Image Viewer
      mpv # Media Player
      sioyek # Document Viewer

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
      colors = {
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

    xdg.configFile."niri/config.kdl".source = pkgs.runCommandLocal "niri-config" { } ''
      cp ${./config.kdl} $out

      chmod +w $out

      substituteInPlace $out \
        --replace-fail "\''${pkgs.swaybg}" "${pkgs.swaybg}/bin/swaybg" \
        --replace-fail "\''${wallpaper}" "${wallpaper}"

      cat <<'EOF' >> $out
      ${extraConfig}
      EOF
    '';

    #xdg.configFile."niri/config.kdl".source = ./config.kdl;

    programs.noctalia-shell = {
      enable = true;
      settings = {
        bar = {
          outerCorners = false;
          widgets = {
            left = [
              {
                id = "ControlCenter";
                useDistroLogo = true;
              }
              {
                id = "ScreenRecorder";
              }
              {
                id = "Tray";
              }
            ];
            center = [
              {
                id = "Workspace";
                labelMode = "none";
              }
            ];
            right = [
              {
                id = "WiFi";
              }
              {
                id = "Bluetooth";
              }
              {
                id = "Volume";
              }
              {
                id = "NotificationHistory";
              }
              {
                id = "Clock";
              }
            ];
          };
        };
        dock.enabled = false;
        colorSchemes.predefinedScheme = "Monochrome";
        general = {
          avatarImage = lib.mkIf (lib.hasAttrByPath [ "user" "name" ] config.programs.git.settings) (
            pkgs.lib.fetchGHUrl {
              gh_username = config.programs.git.settings.user.name;
              hash = avatarHash;
            }
          );
          #radiusRatio = 0.2;
          dimDesktop = false;
          enableShadows = false;
        };
        location = {
          name = "Copenhagen, Denmark";
        };
        wallpaper = {
          enabled = false;
          directory = ../../../dotfiles/wallpapers;
          defaultWallpaper = wallpaper;
        };
        network.wifiEnabled = false;
        notifications.alwaysOnTop = true;
        nightLight.enabled = true;
      };
      # this may also be a string or a path to a JSON file,
      # but in this case must include *all* settings.
    };
  }

  (mkIf useImpermanence {
    home.persistence."/persist${homeDirectory}" = {
      allowOther = true;
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
      ];
    };
  })
]
