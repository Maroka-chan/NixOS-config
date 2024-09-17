{ config, pkgs, inputs, username, ... }:
let
  homeDirectory = "/home/${username}";
  dotfiles = config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/.dotfiles";
in
{
  home = { inherit username homeDirectory; };

  home.packages = with pkgs; [
    pavucontrol # Audio control gui
    
    # Media players
    jellyfin-media-player
    mpv

    feh # Image Viewer

    cava # Audio Visualizer

    sioyek    # Document Viewer
    swaybg    # Wallpaper Tool
    hyprpicker

    # Screenshot
    swappy
    grim
    slurp

    material-design-icons # Icons

    osu-lazer-bin

    sshfs     # Remote filesystems over SSH

    vesktop   # Third-party Discord

    davinci-resolve
    bottles
    inkscape

    inputs.neovim.packages.${pkgs.system}.default
    inputs.tlock.packages.${pkgs.system}.default
  ];

  programs.ags = {
    enable = true;
    configDir = "${dotfiles}/config/ags";
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk
      accountsservice
    ];
  };

  programs.obs-studio = {
    enable = true;
  };

  programs = {
    alacritty.enable = true;
    password-store.enable = true;
    gpg.enable = true;
    git = {
      enable = true;
      userName = "Maroka-chan";
      userEmail = "64618598+Maroka-chan@users.noreply.github.com";
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    firefox = {
      enable = true;
    };
    hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 5;
          hide_cursor = false;
          no_fade_in = false;
        };

        background = [
          {
            path = "screenshot";
            blur_passes = 2;
            blur_size = 2;
          }
        ];

        label = {
            monitor = "";
            text = "           へ            ╱|<br/>૮  -   ՛ )  ♡   (`   -  7.  <br/>/   ⁻  ៸|         |、⁻〵<br/>乀 (ˍ, ل ل         じしˍ,)ノ";
            text_align = "center";
            color = "rgba(243, 241, 141, 1.0)";
            font_size = 12;
            font_family = "Noto Sans";
            rotate = 0; # degrees, counter-clockwise

            position = "0, 80";
            halign = "center";
            valign = "center";
        };

        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline_thickness = 2;
            placeholder_text = "Password...";
          }
        ];
      };
    };
  };

  # Home Manager Persistence
  home.persistence."/persist${homeDirectory}" = {
    allowOther = true;
    files = [
      ".cache/gitstatus/gitstatusd-linux-x86_64"
      ".config/btop/btop.conf"
      ".local/share/nvim/telescope_history"
      ".config/vesktop/settings/settings.json"
      ".config/vesktop/settings.json"
      ".config/vesktop/state.json"
      ".pam-gnupg"
    ];
    directories = [
      "Downloads"
      "Documents"
      "Pictures"
      "Videos"
      "Music"
      ".ssh"
      ".dotfiles"
      ".zplug"
      ".local/share/Jellyfin Media Player/QtWebEngine/Default/Local Storage/leveldb"
      ".config/vesktop/sessionData/Local Storage/leveldb"
      ".local/share/direnv/allow"
      ".local/state/nvim/swap"
      ".local/state/nvim/shada"
      ".local/share/osu"
      ".local/share/password-store"
      ".config/protonmail/bridge-v3"
      ".local/share/protonmail/bridge-v3"
      ".local/share/DaVinciResolve"
      ".local/share/bottles"
      ".local/share/tlock"
      ".local/state/wireplumber"
    ];
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

  services.pass-secret-service.enable = true;
  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    extraConfig = ''
      allow-preset-passphrase
    '';
  };

  # Idle Daemon
  services.hypridle.enable = true;
  services.hypridle.settings = {
    general = {
      after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
    };

    listener = [
      {
        timeout = 300;
        on-timeout = "${pkgs.hyprlock}/bin/hyprlock";
      }
      {
        timeout = 360;
        on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
    ];
  };

  # Eww
  xdg.configFile."eww".source = "${dotfiles}/config/eww";
  
  # Alacritty
  xdg.configFile."alacritty".source = "${dotfiles}/config/alacritty";
}
