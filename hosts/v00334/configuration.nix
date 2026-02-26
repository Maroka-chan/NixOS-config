{
  inputs,
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/disko/btrfs_luks_impermanence.nix
    ../../modules/hardware/gpu/intel.nix
  ];

  impermanence.enable = true;
  filesystem.btrfs.enable = true;

  nix.settings.trusted-users = [username];

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Users
  age.secrets.v00334-password.file = ../../secrets/v00334-password.age;
  users.users.${username} = {
    hashedPasswordFile = config.age.secrets."v00334-password".path;
    #extraGroups = [ "podman" ];
  };

  # Home Manager
  home-manager.users.${username} = {
    imports = [
      ./home.nix
    ];
  };

  boot.plymouth = {
    enable = true;
    themePackages = [pkgs.mikuboot];
    theme = "mikuboot";
  };

  # Desktop Environment
  desktops.niri.enable = true;
  desktops.niri.avatarHash = "sha256-gr/MY41IW26UD48sAjR778ST6LvhnZhgwKRUV8csCCY=";
  desktops.niri.extraConfig = ''
    output "eDP-1" {
        mode "1920x1200@60.0"
        transform "normal"
        scale 1.0
        position x=-1920 y=120
    }

    output "Dell Inc. DELL P3425WE 9XJNY54" {
        mode "3440x1440@99.982"
        scale 1.0
        transform "normal"
        position x=0 y=0
    }
  '';

  # Git
  programs.git.config.user.signingkey = "248853075BFB7C0E";

  # Editor
  programs.neovim-monica = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

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

    # FTDI
    SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6011", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6001", MODE="0666"

    # Jetson
    SUBSYSTEM=="usb", ATTR{idVendor}=="0955", ATTR{idProduct}="7c18", MODE="0666"
  '';

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
