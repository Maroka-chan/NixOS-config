{ inputs, pkgs, lib, config, ... }:
let
  module_name = "neovim";
  cfg = config.configured.programs."${module_name}";
  inherit (lib) mkEnableOption mkOverride mkOption mkIf;
  inherit (lib.types) bool;
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable Neovim";

    defaultEditor = mkOption {
      type = bool;
      default = false;
      description = ''
        Sets the EDITOR envvar to neovim.
      '';
    };

    viAlias = mkOption {
      type = bool;
      default = false;
      description = ''
        Add shell alias vi -> nvim.
      '';
    };

    vimAlias = mkOption {
      type = bool;
      default = false;
      description = ''
        Add shell alias vim -> nvim.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      inputs.neovim.packages.${pkgs.system}.default
    ];

    environment.variables.EDITOR = mkIf cfg.defaultEditor (mkOverride 900 "nvim");

    environment.shellAliases = {
      vi = mkIf cfg.viAlias "nvim";
      vim = mkIf cfg.vimAlias "nvim";
    };
  };
}
