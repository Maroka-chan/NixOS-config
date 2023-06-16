{ config, pkgs, ...}:
let
  impermanence = builtins.fetchTarball "https://github.com/nix-community/impermanence/archive/master.tar.gz";
in
{

  imports = [
    "${impermanence}/home-manager.nix"
  ];

  home.username = "maroka";
  home.homeDirectory = "/home/maroka";

  home.packages = with pkgs; [
    btop
  ];

  programs.zsh.enable = true;

  # Home Manager Persistence
  home.persistence."/persist/home/maroka" = {
    directories = [
      "Downloads"
      "Documents"
      "Pictures"
      "Videos"
      "Music"
      ".ssh"
    ];
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