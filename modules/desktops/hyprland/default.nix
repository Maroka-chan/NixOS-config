{ config, pkgs, lib, username, inputs, ... }:
with lib;
let
  module_name = "hyprland";
  cfg = config.desktops."${module_name}";
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

  config = mkMerge [(mkIf cfg.enable {
    home-manager.extraSpecialArgs = {
      extraHyprConfig = cfg.extraConfig;
      useImpermanence = config.impermanence.enable;
    };
    home-manager.users.${username} = {
      imports = [
        inputs.hyprland.homeManagerModules.default
        inputs.ags.homeManagerModules.default
        inputs.walker.homeManagerModules.default
        ./home.nix
      ];
    };

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # PAM
    security.pam.services.hyprlock = {};
    security.pam.services.greetd.gnupg = {
      enable = true;
      noAutostart = true;
      storeOnly = true;
    };

    # Compositor
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
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

    # Browser
    configured.programs.firefox.enable = true;
    configured.programs.firefox.defaultBrowser = true;

    # Application Launcher
    configured.programs.rofi.enable = true;
    # Terminal Emulator
    configured.programs.zsh.enable = true;
    # File Manager
    configured.programs.thunar.enable = true;
    configured.programs.yazi.enable = true;
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
    programs.ssh.startAgent = true; # gpg-agent emulates ssh-agent. So we can use both SSH and GPG keys.

    # Git
    programs.git = {
      enable = true;
      config = {
        commit.gpgsign = builtins.any (conf: lib.hasAttrByPath [ "user" "signingkey" ] conf) config.programs.git.config;
        core.autocrlf = "input";
      };
    };

    # Podman
    virtualisation.containers.enable = true;
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    # Nix Settings
    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
  })
  (mkIf config.impermanence.enable {
    environment.persistence."/persist" = {
      directories = [
        "/etc/NetworkManager/system-connections"
      ];
      users.${username}.directories = [
        ".gnupg"
      ];
    };
  })];
}

