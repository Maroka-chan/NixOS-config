{
  pkgs,
  lib,
  username,
  ...
}: let
  homeDirectory = "/home/${username}";
in {
  home = {inherit username homeDirectory;};

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
    freecad-qt6
    blender
    darktable

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

  # Home Manager Persistence
  home.persistence."/persist" = {
    files = [
      ".cache/gitstatus/gitstatusd-linux-x86_64"
      ".cache/gstreamer-1.0/registry.x86_64.bin"
      ".config/btop/btop.conf"
      ".local/share/nvim/telescope_history"
      ".config/vesktop/settings/settings.json"
      ".config/vesktop/settings.json"
      ".config/vesktop/state.json"
      ".flutter"
    ];
    directories = [
      "NixOS-config"
      "Projects"
      ".local/share/Jellyfin Media Player/QtWebEngine/Default/Local Storage/leveldb"
      ".config/vesktop/sessionData/Local Storage/leveldb"
      ".config/darktable"
      ".config/blender"
      ".local/share/direnv/allow"
      ".local/state/nvim/swap"
      ".local/state/nvim/shada"
      ".local/share/osu"
      ".local/share/DaVinciResolve"
      ".local/share/PrismLauncher"
      ".dart-tool"
      ".pub-cache"
      ".local/share/Steam"
      ".cache/mesa_shader_cache"
      ".cache/thumbnails/normal"
      ".cache/darktable"
      ".cache/blender/asset-library-indices"
      ".cache/blender/vk-spirv-cache"
    ];
  };
}
