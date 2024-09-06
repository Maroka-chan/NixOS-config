{ pkgs, lib, config, ... }:
with lib;
let
  module_name = "stremio";
  cfg = config.configured.programs."${module_name}";
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable Stremio";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ stremio ];
  };
}
