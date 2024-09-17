{ config, lib, pkgs, inputs, username, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    inputs.home-manager.nixosModule
    ../../modules/base/home-manager.nix
    ../../modules/hardware/gpu/amd.nix
    ../../modules/input/japanese.nix
    inputs.hoyonix.nixosModules.genshin
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

  # Create persist directories
  systemd.tmpfiles.rules = [
    "d /persist/home/${username} 0700 ${username} users"
  ];

  # Home Manager
  home-manager.users.${username} = {
    imports = [
      inputs.impermanence.nixosModules.home-manager.impermanence
      inputs.ags.homeManagerModules.default
      ./home.nix
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    eww
    protonmail-bridge-gui
    wl-clipboard # Wayland Clipboard Utilities
  ];

  ### Programs ###
  # VPN
  configured.programs.mullvad.enable = true;
  configured.programs.mullvad.persist = true;
  # Browser
  configured.programs.librewolf.enable = true;
  configured.programs.librewolf.persist = true;
  configured.programs.librewolf.defaultBrowser = true;
  # Window Manager / Compositor
  configured.programs.hyprland.enable = true;
  configured.programs.hyprland.extraConfig = let
    dotfiles = config.home-manager.users.${username}.lib.file.mkOutOfStoreSymlink "/home/${username}/.dotfiles";
  in ''
    monitor=DP-3,2560x1440@240,1080x240,1
    monitor=HDMI-A-1,1920x1080@60,0x0,1,transform,3

    exec-once = swaybg -i ${dotfiles}/wallpapers/yume_no_kissaten_yumegatari.png -m fill
    exec-once = eww daemon & eww open-many statusbar radio controls
  '';
  # Application Launcher
  configured.programs.rofi.enable = true;
  # Terminal Emulator
  configured.programs.zsh.enable = true;
  configured.programs.zsh.persist = true;
  # Email Client
  configured.programs.thunderbird.enable = true;
  configured.programs.thunderbird.persist = true;
  # File Manager
  configured.programs.thunar.enable = true;
  # Pipewire
  configured.programs.pipewire.enable = true;
  # Games
  programs.genshin = {
    enable = true;
    hdr.enable = true;
    fpsunlock.enable = true;
    mangohud.enable = true;
  };

  programs.steam.enable = true;

  # Git
  programs.git = {
    enable = true;
    config = {
      user.signingkey = "6CF9E05D378A01C5";
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
    (pkgs.callPackage ../../modules/fot-yuruka.nix { inherit pkgs; })
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
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

  security.pam.services.hyprlock = {};

  # Files to persist
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
    ];
    users.${username} = {
      directories = [
        ".gnupg"

        ".umu/hoyoplay"
        ".local/share/umu"
        ".local/share/Steam/compatibilitytools.d"
      ];
    };
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
  system.stateVersion = "23.11";
}
