{ username, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/disko/btrfs.nix
    ../../modules/hardware/gpu/amd.nix
    ../../modules/development/default.nix
  ];

  filesystem.btrfs.enable = true;

  users.mutableUsers = true;
  users.users.${username}.initialPassword = "test123";

  # Home Manager
  home-manager.users.${username} = {
    imports = [
      ./home.nix
    ];
  };

  # Desktop Environment
  desktops.hyprland.enable = true;
  desktops.hyprland.extraConfig = ''
    monitor=DP-3,2560x1440@144,2560x0,1
    monitor=DP-4,2560x1440@60,0x230,1

    exec-once = swaybg -i ${../../dotfiles/wallpapers/makima.png} -m fill
    exec-once = ags run
  '';

  configured.programs.firefox.enableLocalExtensions = false;
  configured.programs.firefox.maxSearchResults = 10;

  # Git
  #programs.git.config.user.signingkey = "6CF9E05D378A01C5";

  ### Programs ###
  # VPN
  configured.programs.mullvad.enable = true;
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
  system.stateVersion = "24.11";
}
