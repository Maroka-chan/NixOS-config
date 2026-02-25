{
  pkgs,
  inputs,
  username,
  ...
}: let
  homeDirectory = "/home/${username}";
in {
  home = {inherit username homeDirectory;};

  home.packages = with pkgs; [
    #swaybg # Wallpaper Tool

    osu-lazer-bin
    sshfs # Remote filesystems over SSH
    vesktop # Third-party Discord

    #davinci-resolve
    #inkscape

    prismlauncher # Minecraft Launcher

    wl-clipboard

    #freecad-wayland
    #blender-hip
    #azpainter
  ];

  programs = {
    git = {
      enable = true;
      settings = {
        user.name = "Maroka-chan";
        user.email = "64618598+Maroka-chan@users.noreply.github.com";
      };
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      silent = true;
    };
    obs-studio.enable = true;
  };

  # Home Manager Persistence
  home.persistence."/persist" = {
    files = [
      ".cache/gitstatus/gitstatusd-linux-x86_64"
      ".config/btop/btop.conf"
      ".local/share/nvim/telescope_history"
      ".config/vesktop/settings/settings.json"
      ".config/vesktop/settings.json"
      ".config/vesktop/state.json"
      ".flutter"
    ];
    directories = [
      ".local/share/Jellyfin Media Player/QtWebEngine/Default/Local Storage/leveldb"
      ".config/vesktop/sessionData/Local Storage/leveldb"
      ".local/share/direnv/allow"
      ".local/state/nvim/swap"
      ".local/state/nvim/shada"
      ".local/share/osu"
      ".local/share/DaVinciResolve"
      ".local/share/PrismLauncher"
      ".dart-tool"
      ".pub-cache"
      ".local/share/Steam"
      ".cache/yuttari"
    ];
  };
}
