{ config, pkgs, inputs, username, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModule
    ../../modules/base/home-manager.nix
  ];

  users.mutableUsers = false;
  networking.networkmanager.enable = true;

  # Filesystem
  filesystem.btrfs = {
    enable = true;
    impermanence.enable = true;
  };

  # Home Manager
  home-manager.users.maroka = {
    home = {
      username = "maroka";
      homeDirectory = "/home/maroka";
    };
    imports = [
      inputs.impermanence.nixosModules.home-manager.impermanence
      ./home.nix
    ];
  };

  # Environment Variables
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    eww

    inotify-tools
    ripgrep
    jq
    socat
    wl-clipboard # Wayland Clipboard Utilities
  ];

  # Window Manager / Compositor
  desktops.hyprland.enable = true;
  desktops.hyprland.extraConfig = let
    dotfiles = config.home-manager.users.${username}.lib.file.mkOutOfStoreSymlink "/home/${username}/.dotfiles";
  in ''
    monitor=,preferred,auto,1

    exec-once = swaybg -i ${dotfiles}/wallpapers/yume_no_kissaten_yumegatari.png -m fill
    exec-once = eww daemon & eww open-many statusbar radio controls
  '';

  # Git
  programs.git = {
    enable = true;
    config = {
      user.signingkey = "D86778C9EE6F81D3";
      commit.gpgsign = true;
      core.autocrlf = "input";
    };
  };

  # Tailscale
  services.tailscale.enable = true;

  # Users
  age.secrets.maroka-password.file = ../../secrets/maroka-password.age;
  users.users.maroka = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPasswordFile = config.age.secrets.maroka-password.path;
  };

  # Set shell
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ]; # Needed for zsh completion for system packages
  users.defaultUserShell = pkgs.zsh;

  # SSH
  programs.ssh.startAgent = true;

  # GNUPG
  programs.gnupg.agent.enable = true;

  # Pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # Bluetooth
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '')
    ];
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    noto-fonts
  ];

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

  # Display Manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
	      user = "greeter";
      };
    };
  };

  # Application Launcher
  configured.programs.rofi.enable = true;

  # Podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # File Manager
  programs.thunar.enable = true;
  services.gvfs.enable = true;

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

  # PAM
  security.pam.services.swaylock = {};

  # Create persist directories
  systemd.tmpfiles.rules = [
    "d /persist/home/maroka 0700 maroka users"
  ];

  # Files to persist
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/mullvad-vpn"
      "/var/lib/fprint"
    ];
  };

  # Automatic Updates
  system.autoUpgrade = {
    enable = true;
    channel = "https://nixos.org/channels/nixos-unstable";
  };

  # Optimise nix store
  nix.settings = {
    auto-optimise-store = true;
    builders-use-substitutes = true;
    substituters = [
      "https://nix-community.cachix.org"
      "https://anyrun.cachix.org"
      "https://devenv.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
    experimental-features = "nix-command flakes";
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
