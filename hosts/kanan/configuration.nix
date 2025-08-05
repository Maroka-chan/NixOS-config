{ config, inputs, username, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/disko/btrfs_luks_impermanence.nix
    ../../modules/hardware/gpu/amd.nix
    ../../modules/input/japanese.nix
    inputs.hoyonix.nixosModules.genshin
  ];

  impermanence.enable = true;
  filesystem.btrfs.enable = true;

  boot.plymouth = {
    enable = true;
    themePackages = [ pkgs.mikuboot ];
    theme = "mikuboot";
  };

  # Needed for uxplay
  #services.avahi = {
  #  nssmdns = true;
  #  enable = true;
  #  publish = {
  #    enable = true;
  #    userServices = true;
  #    domain = true;
  #  };
  #};

  # Users
  age.secrets."${username}-password".file = ../../secrets/${username}-password.age;
  users.users.${username}.hashedPasswordFile = config.age.secrets."${username}-password".path;

  # Home Manager
  home-manager.users.${username} = {
    imports = [
      ./home.nix
    ];
  };

  # Desktop Environment
  desktops.hyprland.enable = true;
  desktops.hyprland.extraConfig = ''
    monitor=DP-3,2560x1440@240,0x0,1

    exec-once = swaybg -i ${../../dotfiles/wallpapers/makima.png} -m fill
    exec-once = ags run --gtk 3
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
  programs.genshin = {
    enable = true;
    hdr.enable = true;
    fpsunlock.enable = true;
    mangohud.enable = true;
  };
  configured.programs.hoyoplay.enable = true;

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
