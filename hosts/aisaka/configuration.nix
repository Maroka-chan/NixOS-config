{
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/disko/btrfs_luks_impermanence.nix
  ];

  impermanence.enable = true;
  filesystem.btrfs.enable = true;

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };

  # Users
  age.secrets.maroka-password.file = ../../secrets/maroka-password.age;
  users.users.maroka.hashedPasswordFile = config.age.secrets.maroka-password.path;
  users.users.maroka.extraGroups = [
    "podman"
  ];

  # Home Manager
  home-manager.users.maroka = {
    imports = [
      ./home.nix
    ];
  };

  # Desktop Environment
  desktops.niri.enable = true;
  desktops.niri.extraConfig = ''
    output "DP-3" {
        mode "1920x1200@60.00"
        scale 1
        transform "normal"
    }
  '';

  # Git
  programs.git.config.user.signingkey = "D86778C9EE6F81D3";

  # Editor
  programs.neovim-monica = {
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

  services.logind.settings.Login.HandleLidSwitch = "suspend";
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
