{
  inputs,
  config,
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/disko/btrfs_luks_impermanence.nix
    ../../modules/hardware/gpu/intel.nix
  ];

  impermanence.enable = true;
  filesystem.btrfs.enable = true;

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
    extraGroups = [ "podman" ];
  };

  # Home Manager
  home-manager.users.${username} = {
    imports = [
      ./home.nix
    ];
  };

  networking.firewall.enable = pkgs.lib.mkForce false;

  boot.plymouth = {
    enable = true;
    themePackages = [ pkgs.mikuboot ];
    theme = "mikuboot";
  };

  # Desktop Environment
  desktops.niri.enable = true;
  desktops.niri.avatarHash = "sha256-gr/MY41IW26UD48sAjR778ST6LvhnZhgwKRUV8csCCY=";
  desktops.niri.extraConfig = ''
    output "DP-3" {
        mode "3840x2160@60.0"
        scale 1.5
        transform "normal"

        // Position of the output in the global coordinate space.
        // This affects directional monitor actions like "focus-monitor-left", and cursor movement.
        // The cursor can only move between directly adjacent outputs.
        // Output scale and rotation has to be taken into account for positioning:
        // outputs are sized in logical, or scaled, pixels.
        // For example, a 3840×2160 output with scale 2.0 will have a logical size of 1920×1080,
        // so to put another output directly adjacent to it on the right, set its x to 1920.
        // If the position is unset or results in an overlap, the output is instead placed
        // automatically.
        //position x=1280 y=0
    }

    output "HDMI-A-1" {
        // Uncomment this line to disable this output.
        // off

        // Resolution and, optionally, refresh rate of the output.
        // The format is "<width>x<height>" or "<width>x<height>@<refresh rate>".
        // If the refresh rate is omitted, niri will pick the highest refresh rate
        // for the resolution.
        // If the mode is omitted altogether or is invalid, niri will pick one automatically.
        // Run `niri msg outputs` while inside a niri instance to list all outputs and their modes.
        mode "3840x2160@60.0"

        // You can use integer or fractional scale, for example use 1.5 for 150% scale.
        scale 1.5

        // Transform allows to rotate the output counter-clockwise, valid values are:
        // normal, 90, 180, 270, flipped, flipped-90, flipped-180 and flipped-270.
        transform "90"

        // Position of the output in the global coordinate space.
        // This affects directional monitor actions like "focus-monitor-left", and cursor movement.
        // The cursor can only move between directly adjacent outputs.
        // Output scale and rotation has to be taken into account for positioning:
        // outputs are sized in logical, or scaled, pixels.
        // For example, a 3840×2160 output with scale 2.0 will have a logical size of 1920×1080,
        // so to put another output directly adjacent to it on the right, set its x to 1920.
        // If the position is unset or results in an overlap, the output is instead placed
        // automatically.
        position x=-1440 y=-560
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

    # Jetson
    SUBSYSTEM=="usb", ATTR{idVendor}=="0955", ATTR{idProduct}="7c18", MODE="0666"
  '';

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
