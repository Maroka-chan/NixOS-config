{
  inputs,
  pkgs,
  username,
  ...
}: let
  homeDirectory = "/home/${username}";
  unstable-pkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  home = {inherit username homeDirectory;};

  home.packages = with pkgs; [
    # Tools
    swaybg # Wallpaper Tool
    sshfs # Remote filesystems over SSH
    wl-clipboard # Clipboard Manager
    rquickshare # Quick Share client
    unstable-pkgs.opencode # LLM Harness

    # Communication Clients
    vesktop # Third-party Discord
    telegram-desktop # Telegram Client
    signal-desktop # Signal
    tutanota-desktop # Mail & Calendar

    # Creative Tools
    inkscape
    gimp3-with-plugins
    blender
    godot
    freecad
    unstable-pkgs.prusa-slicer
    #davinci-resolve

    # Machine Learning
    ollama-rocm # LLM Runner

    # Games
    prismlauncher # Minecraft Launcher

    # Media
    jellyfin-desktop
  ];

  programs = {
    git = {
      enable = true;
      settings = {
        user.name = "Alexander Jacobsen";
        user.email = "dev@alexbmj.com";
      };
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
        obs-vkcapture
      ];
    };
  };
}
