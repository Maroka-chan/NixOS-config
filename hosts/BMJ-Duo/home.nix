{ pkgs, lib, username, ... }:
let
  homeDirectory = "/home/${username}";
in
{
  home = { inherit username homeDirectory; };

  home.packages = with pkgs; [
    # Media Players
    jellyfin-media-player
    qbittorrent

    # Tools
    swaybg    # Wallpaper Tool 
    sshfs     # Remote filesystems over SSH
    wl-clipboard # Clipboard Manager
    fastfetch # Neofetch but faster

    # Communication Clients
    vesktop   # Third-party Discord
    telegram-desktop # Telegram Client

    # Creative Tools
    inkscape
    gimp3-with-plugins
    davinci-resolve
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

