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

  services.pass-secret-service.enable = true;
  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    extraConfig = ''
      allow-preset-passphrase
    '';
  };

  # Eww
  xdg.configFile."eww".source = "${dotfiles}/config/eww";
  
  # Alacritty
  xdg.configFile."alacritty".source = "${dotfiles}/config/alacritty";
}
