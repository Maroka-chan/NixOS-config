{ pkgs, lib, config, username, ... }:
let
  module_name = "stremio";
  cfg = config.configured.programs."${module_name}";
  inherit (lib) mkMerge mkIf mkEnableOption;
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable Stremio";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      environment.systemPackages = with pkgs; [ stremio ];
    })
    (mkIf config.impermanence.enable {
      home-manager.users.${username}.home.persistence
      ."/persist/home/${username}".files = [
        ".local/share/Smart Code ltd/Stremio"
      ];
    })
  ];
}
