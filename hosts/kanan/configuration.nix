{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModule
    inputs.hyprland.nixosModules.default {
      programs.hyprland.enable = true;
    }
    ../../modules/base/home-manager.nix
    ../../modules/hardware/gpu/amd.nix
  ];

  users.mutableUsers = false;
  networking.networkmanager.enable = true;

  # Filesystem
  filesystem.btrfs = {
    enable = true;
    impermanence.enable = true;
  };

  # Create persist directories
  systemd.tmpfiles.rules = [
    "d /persist/home/maroka 0700 maroka users"
  ];

  # Secrets
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.age.keyFile = "/persist/home/maroka/.config/sops/age/keys.txt";

  sops.secrets.maroka-password = {
      neededForUsers = true;
  };

  # Home Manager
  home-manager.users.maroka = {
    home = {
      username = "maroka";
      homeDirectory = "/home/maroka";
      packages = [ inputs.anyrun.packages.${pkgs.system}.anyrun ];
    };
    imports = [
      inputs.impermanence.nixosModules.home-manager.impermanence
      inputs.hyprland.homeManagerModules.default
      inputs.anyrun.homeManagerModules.default
      ./home.nix
    ];
  };

  # Environment Variables
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    btop
    neofetch
    inputs.nixpkgs.legacyPackages.${pkgs.system}.eww-wayland
    protonmail-bridge-gui

    inotify-tools
    ripgrep
    jq
    socat
    wl-clipboard # Wayland Clipboard Utilities

    ffmpegthumbnailer
    nufraw-thumbnailer
  ];

  programs.steam.enable = true;

  xdg.mime.defaultApplications = {
    "text/html"                     = [ "librewolf.desktop" ];
    "x-scheme-handler/http"         = [ "librewolf.desktop" ];
    "x-scheme-handler/https"        = [ "librewolf.desktop" ];
  };

  # Git
  programs.git = {
    enable = true;
    config = {
      user.signingkey = "6CF9E05D378A01C5";
      commit.gpgsign = true;
      core.autocrlf = "input";
    };
  };

  # Users
  users.users.maroka = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPasswordFile = config.sops.secrets.maroka-password.path;
  };

  # Set shell
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ]; # Needed for zsh completion for system packages
  users.defaultUserShell = pkgs.zsh;

  # SSH
  programs.ssh.startAgent = true;

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

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # File Manager
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      tumbler
      thunar-archive-plugin
      thunar-media-tags-plugin
      thunar-volman
    ];
  };
  programs.xfconf.enable = true;
  services.gvfs.enable = true;

  # VPN
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  # PAM
  security.pam.services.login.gnupg = {
    enable = true;
    noAutostart = true;
    storeOnly = true;
  };
  security.pam.services.greetd.gnupg = {
    enable = true;
    noAutostart = true;
    storeOnly = true;
  };
  security.pam.services.swaylock = {};

  # Files to persist
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/mullvad-vpn"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.maroka = {
      directories = [
        ".gnupg"
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
      "https://hyprland.cachix.org"
      "https://anyrun.cachix.org"
      "https://devenv.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
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
  system.stateVersion = "23.11";
}
