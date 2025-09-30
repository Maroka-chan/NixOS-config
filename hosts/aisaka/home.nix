{ pkgs, ... }:
{
  home.packages = with pkgs; [
    swaybg # Wallpaper Tool

    sshfs # Remote filesystems over SSH
    webcord # Third-party Discord
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
  };

  # Home Manager Persistence
  home.persistence."/persist/home/maroka" = {
    files = [
      ".p10k.zsh"
      ".cache/gitstatus/gitstatusd-linux-x86_64"
      ".config/Mullvad VPN/gui_settings.json"
      ".config/WebCord/config.json"
      ".config/btop/btop.conf"
      ".config/cat_installer/ca.pem" # eduroam wifi certificate
      ".local/share/nvim/telescope_history"
    ];
    directories = [
      ".local/share/Jellyfin Media Player/QtWebEngine/Default/Local Storage/leveldb"
      ".config/WebCord/Local Storage/leveldb"
      ".local/share/direnv/allow"
      ".local/state/nvim/swap"
      ".local/state/nvim/shada"
    ];
  };
}
