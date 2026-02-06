{
  pkgs,
  lib,
  config,
  username,
  ...
}: let
  module_name = "stremio";
  cfg = config.configured.programs."${module_name}";
  inherit (lib) mkMerge mkIf mkEnableOption;
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable Stremio";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      environment.systemPackages = [(pkgs.callPackage ../../pkgs/stremio-linux-shell.nix {})];
    })
    (mkIf config.impermanence.enable {
      home-manager.users.${username}.home.persistence."/persist".directories = [
        ".local/share/stremio"
      ];
    })
  ];
}
