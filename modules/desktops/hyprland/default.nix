{ config, pkgs, lib, username, inputs, ... }:
with lib;
let
  module_name = "hyprland";
  cfg = config.desktops."${module_name}";

  Hyprland = pkgs.writeShellApplication {
    name = "Hyprland";
    runtimeInputs = [ inputs.hyprland.packages.${pkgs.system}.hyprland ];
    runtimeEnv = {
      #XDG_CONFIG_HOME = ../../../dotfiles;
      HYPRPLUGIN_PATH = pkgs.symlinkJoin {
        name = "hyprland-plugins";
        paths = [ inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces ];
      };
    };
    text = let
      path = lib.makeBinPath [ inputs.ags.packages.${pkgs.system}.io ];
    in "
      export PATH=${path}:$PATH
      Hyprland
    ";
  };

  #xdg.configFile."hypr/hyprland.conf".source = ../../../dotfiles/hypr/hyprland.conf;
  #specialisation.dotfiles.configuration.xdg.configFile."hypr/hyprland.conf".source = lib.mkForce (config.lib.file.mkOutOfStoreSymlink "/home/maroka/Documents/NixOS-config/dotfiles/hypr/hyprland.conf");
in {
  options.desktops."${module_name}" = {
    enable = mkEnableOption "Enable the Hyprland Wayland Compositor";
    extraConfig = mkOption {
      type = types.str;
      default = "";
    };
  };

  imports = [
    ../../home-manager.nix
  ];

  config = mkIf cfg.enable ( mkMerge [{
    home-manager.extraSpecialArgs = {
      extraHyprConfig = cfg.extraConfig;
      useImpermanence = config.impermanence.enable;
    };
    home-manager.users.${username} = {
      imports = [
        #inputs.hyprland.homeManagerModules.default
        inputs.ags.homeManagerModules.default
        inputs.walker.homeManagerModules.default
        ./home.nix
      ];
    };

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    #environment.systemPackages = with pkgs; [
    #  #hyprpolkitagent
    #  #hyprsunset
    #];

    # PAM
    security.pam.services.hyprlock = {};
    security.pam.services.greetd.gnupg = {
      enable = true;
      noAutostart = true;
      storeOnly = true;
    };

    # Networking
    services.resolved.enable = true;
    networking.networkmanager.enable = true;
    users.users.${username}.extraGroups = [ "networkmanager" ];



    # Compositor
    #programs.hyprland.enable = true;
    #programs.hyprland.package = let
    #in Hyprland;
    environment.systemPackages = [ Hyprland ];

    xdg.portal = {
      enable = true;
      extraPortals = [ (pkgs.xdg-desktop-portal-hyprland.override { hyprland = Hyprland; }) ];
      configPackages = lib.mkDefault [ Hyprland ];
    };

    security.polkit.enable = true;
    programs.xwayland.enable = true;
    programs.dconf.enable = true;

    # NOTE: Do we need this?
    # Window manager only sessions (unlike DEs) don't handle XDG
    # autostart files, so force them to run the service
    services.xserver.desktopManager.runXdgAutostartIfNone = true;

    #systemd.user.tmpfiles.rules = [ "L+ %h - - - " ];
    systemd.user.tmpfiles.rules = [
      "L+ %h/.config/hypr/hyprland.conf - - - - ${../../../dotfiles/hypr/hyprland.conf}"
    ];
    #specialisation.dotfiles.configuration.systemd.user.tmpfiles.rules = [
    #  "L+ %h/.config/hypr/hyprland.conf - - - - %h/Documents/NixOS-config/dotfiles/hypr/hyprland.conf"
    #];



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

    # Browser
    configured.programs.firefox.enable = true;
    configured.programs.firefox.defaultBrowser = true;

    # Application Launcher
    configured.programs.rofi.enable = true;
    # Terminal Emulator
    configured.programs.zsh.enable = true;
    # File Manager
    configured.programs.thunar.enable = true;
    # Pipewire
    configured.programs.pipewire.enable = true;

    # Email Client
    configured.programs.thunderbird.enable = true;
    # Protonmail Bridge
    systemd.user.services.protonmail-bridge.environment.PASSWORD_STORE_DIR = "/home/${username}/.local/share/password-store";
    services.protonmail-bridge = {
      enable = true;
      path = [ pkgs.pass ];
    };

    # NOTE: mkIf bluetooth?
    # Bluetooth
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    # Fonts
    fonts.packages = with pkgs; [
      nerd-fonts.caskaydia-cove
      noto-fonts
    ];

    # SSH
    programs.ssh.startAgent = false; # gpg-agent emulates ssh-agent. So we can use both SSH and GPG keys.

    # Git
    programs.git = {
      enable = true;
      config = {
        commit.gpgsign = true;
        core.autocrlf = "input";
      };
    };

    # Podman
    virtualisation.containers.enable = true;
    virtualisation.docker.enable = true;
    virtualisation.docker.storageDriver = "btrfs";
    virtualisation.docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
    #virtualisation.podman = {
    #  enable = true;
    #  dockerCompat = true;
    #  dockerSocket.enable = true;
    #  defaultNetwork.settings.dns_enabled = true;
    #};

    # Nix Settings
    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  }
  (mkIf config.impermanence.enable {
    environment.persistence."/persist" = {
      directories = [
        "/etc/NetworkManager/system-connections"
      ];
      users.${username}.directories = [
        ".gnupg"
      ];
    };
  })]);
}

