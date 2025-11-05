{
  config,
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/disko/btrfs_luks_impermanence.nix
    ../../modules/hardware/gpu/amd.nix
    ../../modules/input/japanese.nix
  ];

  nix.settings.trusted-users = [ "maroka" ];

  impermanence.enable = true;
  filesystem.btrfs.enable = true;

  xdg.portal.config.common."org.freedesktop.impl.portal.AppChooser" = "gtk";

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  boot.plymouth = {
    enable = true;
    themePackages = [ pkgs.mikuboot ];
    theme = "mikuboot";
  };

  fonts.packages = with pkgs; [
    material-symbols
    nerd-fonts.jetbrains-mono
    ibm-plex
  ];

  # Users
  age.secrets."${username}-password".file = ../../secrets/${username}-password.age;
  users.users.${username} = {
    hashedPasswordFile = config.age.secrets."${username}-password".path;
  };

  # Home Manager
  home-manager.users.${username} = {
    imports = [
      ./home.nix
    ];
  };

  # Desktop Environment
  #desktops.hyprland.enable = true;
  #desktops.hyprland.extraConfig = ''
  #  monitor=DP-3,2560x1440@240,0x0,1

  #  exec-once = swaybg -i ${../../dotfiles/wallpapers/makima.png} -m fill
  #  exec-once = ags run --gtk 3
  #'';
  desktops.niri.enable = true;
  desktops.niri.extraConfig = ''
    output "DP-3" {
        mode "3840x2160@60.0"
        scale 1
        transform "normal"
    }
  '';

  # Git
  programs.git.config.user.signingkey = "6CF9E05D378A01C5";

  ### Programs ###
  # VPN
  configured.programs.mullvad.enable = true;
  # Stremio
  configured.programs.stremio.enable = true;
  # Games
  programs.steam.enable = true;

  # Editor
  configured.programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
