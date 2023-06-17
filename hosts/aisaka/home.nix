{ config, pkgs, ...}: {

  home.packages = with pkgs; [
    git
  ];

  programs.zsh.enable = true;

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
    ];
  };

  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
  };

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