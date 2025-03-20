{ config, pkgs, username, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/disko/btrfs_luks_impermanence.nix
  ];

  impermanence.enable = true;
  filesystem.btrfs.enable = true;

  # Users
  age.secrets.v00334-password.file = ../../secrets/v00334-password.age;
  users.users.${username}.hashedPasswordFile = config.age.secrets."v00334-password".path;

  # Home Manager
  home-manager.users.${username} = {
    imports = [
      ./home.nix
    ];
  };

  # Desktop Environment
  desktops.hyprland.enable = true;
  desktops.hyprland.extraConfig = let
    dotfiles = config.home-manager.users.${username}.lib.file.mkOutOfStoreSymlink "/home/${username}/.dotfiles";
  in ''
    monitor=DP-3,3840x2160,-1440x-560,1.5,transform,1
    monitor=HDMI-A-1,3840x2160,0x0,1.5
    monitor=eDP-1,preferred,auto,1

    exec-once = swaybg -i ${dotfiles}/wallpapers/yume_no_kissaten_yumegatari.png -m fill
    exec-once = ags run
  '';

  # Git
  programs.git.config.user.signingkey = "248853075BFB7C0E";

  # Power Management
  #services.tlp = {
  #  enable = true;
  #  settings = {
  #    START_CHARGE_THRESH_BAT0 = 20;
  #    STOP_CHARGE_THRESH_BAT0 = 80;
  #    CPU_BOOST_ON_AC = 1;
  #    CPU_BOOST_ON_BAT = 1;
  #    CPU_SCALING_GOVERNOR_ON_AC = "performance";
  #    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
  #  };
  #};

  #services.logind.lidSwitch = "suspend";
  #services.upower.enable = true;

  # Fingerprint Reader
  #services.fprintd = {
  #  enable = true;
  #};

  # Udev rules
  ## Brightness
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
