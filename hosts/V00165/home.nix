{ pkgs, lib, username, ... }:
let
  homeDirectory = "/home/${username}";
in
{
  home = { inherit username homeDirectory; };

  home.packages = with pkgs; [
    # Tools
    swaybg    # Wallpaper Tool
    sshfs     # Remote filesystems over SSH
    wl-clipboard # Clipboard Manager

    zoom-us
    slack
  ];

  programs = {
    git = {
      enable = true;
      userName = "AlexBMJ";
      userEmail = "33891167+AlexBMJ@users.noreply.github.com";
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };
  };


}

