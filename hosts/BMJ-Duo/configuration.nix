{
  username,
  lib,
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/disko/btrfs_luks_impermanence.nix
    ../../modules/hardware/gpu/amd.nix
    ../../modules/development/default.nix
    ./niri.nix
    inputs.nixos-hardware-gpdduo.nixosModules.gpd-duo
  ];

  filesystem.btrfs.enable = true;

  users.mutableUsers = false;
  age.secrets."${username}-password".file = ../../secrets/${username}-password.age;
  users.users.${username} = {
    hashedPasswordFile = config.age.secrets."${username}-password".path;
    extraGroups = ["wireshark"];
  };

  nix.settings.trusted-users = ["${username}"];

  # Home Manager
  home-manager.users.${username} = {
    imports = [
      ./home.nix
    ];
  };

  configured.programs.firefox.enableLocalExtensions = false;
  configured.programs.firefox.maxSearchResults = 10;

  services = {
    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          energy_performance_preference = "power";
          governor = "powersave";
          turbo = "auto";
        };
        charger = {
          energy_performance_preference = "performance";
          governor = "performance";
          turbo = "always";
        };
      };
    };
    upower.enable = true;
    logind.settings.Login.HandleLidSwitch = "suspend";

    fprintd.enable = true;

    tailscale = {
      enable = true;
      openFirewall = true;
    };

    ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
    };
  };

  systemd.services.tailscaled.wantedBy = lib.mkForce [];

  networking.firewall = {
    allowedTCPPorts = [];
    allowedUDPPorts = [];
  };

  # Git
  #programs.git.config.user.signingkey = "6CF9E05D378A01C5";

  ### Programs ###
  # VPN
  configured.programs.mullvad.enable = true;
  # Games
  programs.steam.enable = true;

  # Utils
  programs.cnping.enable = true;
  programs.kdeconnect.enable = true;

  # Editors
  programs.neovim-monica = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
    usbmon.enable = true;
    dumpcap.enable = true;
  };

  configured.programs.vscodium = {
    enable = true;
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl1", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
