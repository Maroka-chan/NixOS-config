{
  username,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/hardware/gpu/amd.nix
    ../../modules/development/default.nix
    ../../modules/disko/btrfs_luks_impermanence.nix
    ./niri.nix
  ];

  filesystem.btrfs.enable = true;

  users.mutableUsers = true;
  users.users.${username} = {
    initialPassword = "password";
    extraGroups = [
      "networkmanager"
      "dialout"
      "podman"
    ];
  };

  nix.settings.trusted-users = ["${username}"];

  # Home Manager
  home-manager.users.${username} = {
    imports = [
      ./home.nix
    ];
  };

  services.resolved.enable = true;
  services.upower.enable = true;
  networking.networkmanager.enable = true;

  services = {
    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          energy_performance_preference = "performance";
          governor = "performance";
          turbo = "always";
          enable_thresholds = true;
          start_threshold = 60;
          stop_threshold = 80;
        };
        charger = {
          energy_performance_preference = "performance";
          governor = "performance";
          turbo = "always";
        };
      };
    };
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
      };
    };
    tailscale = {
      enable = true;
      openFirewall = true;
    };
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  systemd.services.cups.wantedBy = lib.mkForce [];
  systemd.services.sshd.wantedBy = lib.mkForce [];

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Git
  #programs.git.config.user.signingkey = "6CF9E05D378A01C5";

  ### Programs ###

  configured.programs.firefox.enableLocalExtensions = false;
  configured.programs.firefox.maxSearchResults = 10;

  # Editors
  programs.neovim-monica = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # cnping
  programs.cnping.enable = true;

  configured.programs.vscode.enable = true;

  networking.firewall.allowedUDPPorts = [
    53
    67
    68
  ];

  services.udev.extraRules = ''
        # Backlight
        ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl1", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"

        # FTDI
        SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6011", MODE="0666"

        # Jetson
        SUBSYSTEM=="usb", ATTR{idVendor}=="0955", ATTR{idProduct}="7c18", MODE="0666"

        # ADVANTECH QCOM
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="05c6", ATTRS{idProduct}=="9008", MODE="0666",
    GROUP="plugdev"
  '';

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
