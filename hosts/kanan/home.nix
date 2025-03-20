{ pkgs, inputs, username, ... }:
let
  homeDirectory = "/home/${username}";
in
{
  home = { inherit username homeDirectory; };

  home.packages = with pkgs; [
    # Media players
    jellyfin-media-player

    swaybg    # Wallpaper Tool

    osu-lazer-bin
    sshfs     # Remote filesystems over SSH
    vesktop   # Third-party Discord

    davinci-resolve
    bottles
    inkscape

    prismlauncher # Minecraft Launcher

    inputs.neovim.packages.${pkgs.system}.default
    wl-clipboard
  ];

  programs = {
    git = {
      enable = true;
      userName = "Maroka-chan";
      userEmail = "64618598+Maroka-chan@users.noreply.github.com";
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    obs-studio.enable = true;
  };

  # Home Manager Persistence
  home.persistence."/persist${homeDirectory}" = {
    files = [
      ".cache/gitstatus/gitstatusd-linux-x86_64"
      ".config/btop/btop.conf"
      ".local/share/nvim/telescope_history"
      ".config/vesktop/settings/settings.json"
      ".config/vesktop/settings.json"
      ".config/vesktop/state.json"
    ];
    directories = [
      ".local/share/Jellyfin Media Player/QtWebEngine/Default/Local Storage/leveldb"
      ".config/vesktop/sessionData/Local Storage/leveldb"
      ".local/share/direnv/allow"
      ".local/state/nvim/swap"
      ".local/state/nvim/shada"
      ".local/share/osu"
      ".local/share/DaVinciResolve"
      ".local/share/bottles"
      ".local/share/PrismLauncher"
      {directory = ".local/share/Steam"; method = "symlink";}
    ];
  };

  
}
