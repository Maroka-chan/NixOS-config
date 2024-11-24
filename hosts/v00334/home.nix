{ config, pkgs, inputs, username, ... }:
let

  homeDirectory = "/home/${username}";
  dotfiles = config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/.dotfiles";
in
{
  home.packages = with pkgs; [
    pavucontrol # Audio control gui
    
    # Media players
    mpv

    feh # Image Viewer

    #cava # Audio Visualizer

    sioyek    # Document Viewer
    swaybg    # Wallpaper Tool

    # Screenshot
    swappy
    grim
    slurp

    material-design-icons # Icons
    slack

    inputs.neovim.packages.${pkgs.system}.default
  ];

  programs = {
    alacritty.enable = true;
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
    firefox.enable = true;
  };

  # Home Manager Persistence
  home.persistence."/persist${homeDirectory}" = {
    allowOther = true;
    files = [
      ".cache/gitstatus/gitstatusd-linux-x86_64"
      ".config/btop/btop.conf"
      ".local/share/nvim/telescope_history"
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
      ".local/share/direnv/allow"
      ".local/state/nvim/swap"
      ".local/state/nvim/shada"
      ".local/share/password-store"
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
