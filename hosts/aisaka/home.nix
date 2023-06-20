{ config, pkgs, ...}:
let
  dotfiles = config.lib.file.mkOutOfStoreSymlink "/home/maroka/.dotfiles/config";
in
{

  home.packages = with pkgs; [
    git
    alacritty
    pavucontrol
    firefox
    brave
    librewolf
  ];

  programs = {
    zsh.enable = true;
    git = {
      enable = true;
      userName = "Maroka-chan";
      userEmail = "64618598+Maroka-chan@users.noreply.github.com";
    };
  };

  # Home Manager Persistence
  home.persistence."/persist/home/maroka" = {
    allowOther = false;
    directories = [
      "Downloads"
      "Documents"
      "Pictures"
      "Videos"
      "Music"
      ".ssh"
      ".dotfiles"
    ];
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 22;
  };

  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      monitor=,preferred,auto,auto

      exec-once = eww daemon & eww open bar

      input {
        scroll_method = "2fg"
	sensitivity = 0
        touchpad {
          natural_scroll = true
	  scroll_factor = 0.2
	}
      }

      bind = SUPER SHIFT, Q, killactive
      bind = SUPER, F, fullscreen
      bind = SUPER, D, exec, anyrun
      bind = SUPER, Return, exec, alacritty
    '';
  };

  # Eww
  xdg.configFile."eww".source = "${dotfiles}/eww";

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
  home.stateVersion = "23.05";
}
