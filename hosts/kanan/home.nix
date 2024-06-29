{ config, pkgs, inputs, username, ...}:
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
    swayidle  # Idle management
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
    blender-hip
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
    alacritty = {
      enable = true;
    };
    password-store.enable = true;
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
    swaylock = {
      enable = true;
    };
    gpg.enable = true;
   # hyprlock = {
   #   enable = true;
   #   backgrounds = [{
   #     path = "screenshot";
   #   }];
   #   input-fields = [{
   #     
   #   }];
   # };
  };

  # Home Manager Persistence
  home.persistence."/persist${homeDirectory}" = {
    allowOther = true;
    files = [
      ".cache/gitstatus/gitstatusd-linux-x86_64"
      ".config/btop/btop.conf"
      ".local/share/nvim/telescope_history"
      ".config/sops/age/keys.txt"
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
  services.swayidle = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    events = [
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f -c 000000"; }
    ];
    timeouts = [
      { timeout = 300; command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off"; resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on"; }
      { timeout = 320; command = "${pkgs.swaylock}/bin/swaylock -f -c 000000"; }
    ];
  };

  # Eww
  xdg.configFile."eww".source = "${dotfiles}/config/eww";
  
  # Alacritty
  xdg.configFile."alacritty".source = "${dotfiles}/config/alacritty";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";
}

