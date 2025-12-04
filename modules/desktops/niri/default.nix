{
  config,
  lib,
  pkgs,
  username,
  inputs,
  ...
}:
let
  module_name = "niri";
  cfg = config.desktops."${module_name}";
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    mkEnableOption
    types
    ;
in
{
  options.desktops."${module_name}" = {
    enable = mkEnableOption "Enable the Niri Wayland Compositor";
    extraConfig = mkOption {
      type = types.str;
      default = "";
    };
    avatarHash = mkOption {
      type = types.str;
      default = lib.fakeHash;
    };
    wallpaper = mkOption {
      type = types.path;
      default = ../../../dotfiles/wallpapers/miku_nakano.png;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.niri.enable = true;

      # PAM
      security.pam.services.greetd.gnupg = {
        enable = true;
        noAutostart = true;
        storeOnly = true;
      };

      # Display Manager
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
            user = "greeter";
          };
        };
      };

      # Browser
      configured.programs.firefox.enable = true;
      configured.programs.firefox.defaultBrowser = true;

      # Terminal Emulator
      configured.programs.zsh.enable = true;
      # File Manager
      configured.programs.thunar.enable = true;
      # Pipewire
      configured.programs.pipewire.enable = true;

      environment.systemPackages = with pkgs; [
        material-design-icons # Icons

        inputs.noctalia.packages.${system}.default # Quickshell bar
        xwayland-satellite # Niri uses xwayland-satellite for Xwayland
      ];

      # Fonts
      fonts.packages = with pkgs; [
        nerd-fonts.caskaydia-cove
        noto-fonts
      ];

      # Bluetooth
      hardware.bluetooth.enable = true;

      home-manager.extraSpecialArgs = {
        useImpermanence = config.impermanence.enable;
        inherit (cfg) extraConfig wallpaper avatarHash;
      };
      home-manager.users.${username} = {
        imports = [
          ./home.nix
          inputs.noctalia.homeModules.default
        ];
      };

      # Fix xdg portals
      # https://cashmere.rs/blog/20250612002456-how_to_fix_screensharing_for_niri_wm_under_nixos.html
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-gnome
        ];
        config = {
          common = {
            default = [ "gtk" ];
          };
          niri = {
            default = [
              "gtk"
              "gnome"
            ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
          };
        };
      };

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_DESKTOP = "niri";
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
    })
  ]);
}
