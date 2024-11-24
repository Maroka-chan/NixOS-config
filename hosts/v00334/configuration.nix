{ config, pkgs, inputs, username, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    inputs.home-manager.nixosModule
    ../../modules/base/home-manager.nix
  ];

  # Networking
  services.resolved.enable = true;
  networking.networkmanager.enable = true;

  # Filesystem
  filesystem.btrfs = {
    enable = true;
    impermanence.enable = true;
  };

  # Users
  age.secrets.maroka-password.file = ../../secrets/maroka-password.age;
  users.mutableUsers = false;
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPasswordFile = config.age.secrets."${username}-password".path;
  };

  # Home Manager
  home-manager.users.${username}.imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
    ./home.nix
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    eww
    wl-clipboard # Wayland Clipboard Utilities
  ];

  ### Programs ###
  # Browser
  configured.programs.librewolf.enable = true;
  configured.programs.librewolf.persist = true;
  configured.programs.librewolf.defaultBrowser = true;
  # Window Manager / Compositor
  desktops.hyprland.enable = true;
  desktops.hyprland.extraConfig = let
    dotfiles = config.home-manager.users.${username}.lib.file.mkOutOfStoreSymlink "/home/${username}/.dotfiles";
  in ''
    monitor=DP-3,3840x2160,-1440x-560,1.5,transform,1
    monitor=HDMI-A-1,3840x2160,0x0,1.5
    monitor=eDP-1,preferred,auto,1

    exec-once = swaybg -i ${dotfiles}/wallpapers/yume_no_kissaten_yumegatari.png -m fill
    exec-once = eww daemon & eww open statusbar
  '';
  # Application Launcher
  configured.programs.rofi.enable = true;
  # Terminal Emulator
  configured.programs.zsh.enable = true;
  configured.programs.zsh.persist = true;
  # File Manager
  configured.programs.thunar.enable = true;
  # Pipewire
  configured.programs.pipewire.enable = true;

  # Git
  programs.git = {
    enable = true;
    config = {
      user.signingkey = "D86778C9EE6F81D3";
      commit.gpgsign = true;
      core.autocrlf = "input";
    };
  };

  # SSH
  programs.ssh.startAgent = false; # gpg-agent emulates ssh-agent. So we can use both SSH and GPG keys.

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    noto-fonts
  ];

  # Podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Power Management
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 20;
      STOP_CHARGE_THRESH_BAT0 = 80;
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 1;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };

  services.logind.lidSwitch = "suspend";
  services.upower.enable = true;

  # Fingerprint Reader
  services.fprintd = {
    enable = true;
  };

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

  # PAM
  security.pam.services.greetd.gnupg = {
    enable = true;
    noAutostart = true;
    storeOnly = true;
  };

  # Files to persist
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
    ];
    users.${username} = {
      directories = [
        ".gnupg"
      ];
    };
  };

  # Udev rules
  ## Brightness
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';

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
      "https://devenv.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
    experimental-features = "nix-command flakes";
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
