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
  home-manager.users.maroka = {
    imports = [
      ./home.nix
    ];
  };

  # Desktop Environment
  desktops.hyprland.enable = true;
  desktops.hyprland.extraConfig = let
    dotfiles = config.home-manager.users.${username}.lib.file.mkOutOfStoreSymlink "/home/${username}/.dotfiles";
  in ''
    monitor=DP-3,2560x1440@240,1080x240,1
    monitor=HDMI-A-1,1920x1080@60,0x0,1,transform,3

    exec-once = swaybg -i ${dotfiles}/wallpapers/yume_no_kissaten_yumegatari.png -m fill
    exec-once = ags run
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


  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
