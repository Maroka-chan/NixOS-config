{
  lib,
  config,
  username,
  ...
}:
with lib; let
  module_name = "thunderbird";
  cfg = config.configured.programs."${module_name}";
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable Thunderbird Email Client";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home-manager.users.${username} = {
        programs.thunderbird = {
          enable = true;
          settings = {
            "general.useragent.override" = "";
            "privacy.donottrackheader.enabled" = true;
          };
          profiles.main = {
            isDefault = true;
          };
        };
      };
    })
    (mkIf config.impermanence.enable {
      home-manager.users.${username}.home.persistence
      ."/persist".directories = [
        ".thunderbird"
      ];
    })
  ];
}
