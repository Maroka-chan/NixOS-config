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
    inputs.home-manager.nixosModule
    inputs.hyprland.nixosModules.default
  ];

  config = mkIf cfg.enable {
    home-manager.extraSpecialArgs.extraHyprConfig = cfg.extraConfig;
    home-manager.users.${username} = {
      imports = [
        inputs.hyprland.homeManagerModules.default
        inputs.ags.homeManagerModules.default
        ./home.nix
      ];
    };

    security.pam.services.hyprlock = {};

    environment.systemPackages = with pkgs; [
      #hyprpolkitagent
      #hyprsunset
    ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    programs.hyprland.enable = true;

    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };
}

