{
  pkgs,
  lib,
  username,
  ...
}:
let
  homeDirectory = "/home/${username}";
in
{
  home = { inherit username homeDirectory; };

  home.packages = with pkgs; [
    # Tools
    swaybg # Wallpaper Tool
    sshfs # Remote filesystems over SSH
    wl-clipboard # Clipboard Manager
    rquickshare # Quick Share client

    # Communication Clients
    vesktop # Third-party Discord
    telegram-desktop # Telegram Client
    signal-desktop # Signal

    # Creative Tools
    inkscape
    gimp3-with-plugins
    #davinci-resolve
    blender-hip

    # Machine Learning
    ollama-rocm # LLM Runner

    # Games
    prismlauncher # Minecraft Launcher
  ];

  programs = {
    git = {
      enable = true;
      settings = {
        user.name = "AlexBMJ";
        user.email = "33891167+AlexBMJ@users.noreply.github.com";
      };
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };
    obs-studio.enable = true;
  };
}
