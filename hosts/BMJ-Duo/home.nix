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
    qbittorrent

    # Tools
    swaybg # Wallpaper Tool
    sshfs # Remote filesystems over SSH
    wl-clipboard # Clipboard Manager
    fastfetch # Neofetch but faster

    # Communication Clients
    vesktop # Third-party Discord
    telegram-desktop # Telegram Client
    signal-desktop # Signal

    # Creative Tools
    inkscape
    gimp3-with-plugins
    blender-hip
    freecad-qt6

    # Machine Learning
    ollama-rocm # LLM Runner

    # Games
    prismlauncher # Minecraft Launcher
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
    obs-studio.enable = true;
  };
}
