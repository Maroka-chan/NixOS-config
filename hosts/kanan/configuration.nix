{ config, pkgs, inputs, username, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModule
    ../../modules/base/home-manager.nix
    ../../modules/hardware/gpu/amd.nix
    ../../modules/input/japanese.nix
  ];

  services.resolved.enable = true;

  xdg.portal.enable = true;

  users.mutableUsers = false;
  networking.networkmanager.enable = true;

  # Filesystem
  filesystem.btrfs = {
    enable = true;
    impermanence.enable = true;
  };

  # Create persist directories
  systemd.tmpfiles.rules = [
    "d /persist/home/${username} 0700 ${username} users"
  ];

  # Secrets
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.age.keyFile = "/persist/home/${username}/.config/sops/age/keys.txt";

  sops.secrets."${username}-password" = {
      neededForUsers = true;
  };

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
    btop
    neofetch
    eww
    protonmail-bridge-gui

    inotify-tools
    ripgrep
    jq
    socat
    wl-clipboard # Wayland Clipboard Utilities

    ffmpegthumbnailer
    nufraw-thumbnailer
  ];

  # Programs
  # An Anime Game Launcher
  configured.programs.aagl.enable = true;
  configured.programs.aagl.persist = true;
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

    windowrulev2 = idleinhibit fullscreen,class:(org.jellyfin.),title:(Jellyfin Media Player)
  '';

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

  # Main user
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPasswordFile = config.sops.secrets."${username}-password".path;
  };

  # Set shell
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ]; # Needed for zsh completion for system packages
  users.defaultUserShell = pkgs.zsh;

  # SSH
  programs.ssh.startAgent = false; # gpg-agent emulates ssh-agent. So we can use both SSH and GPG keys.

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

  security.pam.services.swaylock = {};

  # Files to persist
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.${username} = {
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
  system.stateVersion = "23.11";
}
