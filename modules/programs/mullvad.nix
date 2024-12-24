{ pkgs, lib, config, username, ... }:
with lib;
let
  module_name = "mullvad";
  cfg = config.configured.programs."${module_name}";
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable Mullvad VPN Client";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.mullvad-vpn = {
        enable = true;
        package = pkgs.mullvad-vpn;
      };
    })
    (mkIf config.impermanence.enable {
      environment.persistence."/persist" = {
        directories = [
          "/etc/mullvad-vpn"
        ];
      };
      home-manager.users.${username}.home.persistence
      ."/persist/home/${username}".files = [
        ".config/Mullvad VPN/gui_settings.json"
      ];
    })
  ];
}

