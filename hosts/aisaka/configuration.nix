{ config, pkgs, username, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/disko/btrfs_luks_impermanence.nix
  ];

  impermanence.enable = true;
  filesystem.btrfs.enable = true;

  # Users
  age.secrets.maroka-password.file = ../../secrets/maroka-password.age;
  users.users.maroka.hashedPasswordFile = config.age.secrets.maroka-password.path;

  # Home Manager
  home-manager.users.maroka = {
    imports = [
      ./home.nix
    ];
  };

  # Desktop Environment
  desktops.hyprland.enable = true;
  desktops.hyprland.extraConfig = ''
    monitor=,preferred,auto,1

    exec-once = swaybg -i ${../../dotfiles/wallpapers/makima.png} -m fill
    exec-once = ags run
  '';

  # Git
  programs.git.config.user.signingkey = "D86778C9EE6F81D3";

  # Editor
  configured.programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Tailscale
  services.tailscale.enable = true;

  # Power Management
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        energy_performance_preference = "power";
        governor = "powersave";
        turbo = "always";
        enable_thresholds = true;
        start_threshold = 20;
        stop_threshold = 80;
      };
      charger = {
        energy_performance_preference = "performance";
        governor = "performance";
        turbo = "always";
      };
    };
  };

  services.logind.lidSwitch = "suspend";
  services.upower.enable = true;

  # VPN
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  # Fingerprint Reader
  services.fprintd = {
    enable = true;
  };

  # Udev rules
  ## Brightness
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';

  # Files to persist
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/fprint"
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
