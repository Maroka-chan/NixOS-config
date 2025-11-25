{ pkgs, username, ... }:
let
  homeDirectory = "/home/${username}";
in
{
  home = { inherit username homeDirectory; };

  home.packages = with pkgs; [
    swaybg # Wallpaper Tool
    slack

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
      silent = true;
    };
  };

  # Home Manager Persistence
  home.persistence."/persist${homeDirectory}" = {
    files = [
      ".cache/gitstatus/gitstatusd-linux-x86_64"
      ".config/btop/btop.conf"
      ".local/share/nvim/telescope_history"
    ];
    directories = [
      ".local/share/direnv/allow"
      ".local/state/nvim/swap"
      ".local/state/nvim/shada"
      ".cache/flashing-station-rs"
      ".config/Slack"
    ];
  };
}
