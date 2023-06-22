{ config, pkgs, ...}:
let
  dotfiles = config.lib.file.mkOutOfStoreSymlink "/home/maroka/.dotfiles";
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
    allowOther = true;
    directories = [
      "Downloads"
      "Documents"
      "Pictures"
      "Videos"
      "Music"
      ".ssh"
      ".dotfiles"
      ".config/BraveSoftware/Brave-Browser"
      ".librewolf"
    ];
  };

  gtk.enable = true; # Needs to be enabled for home.pointerCursor to actually write gtk XDG settings files
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
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

      $mainMod = SUPER

      bind = $mainMod SHIFT, Q, killactive
      bind = $mainMod, F, fullscreen
      bind = $mainMod, D, exec, anyrun
      bind = $mainMod, Return, exec, alacritty

      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10
    '';
  };

  # Eww
  xdg.configFile."eww".source = "${dotfiles}/config/eww";

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
