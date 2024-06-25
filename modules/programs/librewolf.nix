{ lib, config, username, ... }:
with lib;
let
  module_name = "librewolf";
  cfg = config.configured.programs."${module_name}";
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable the Librewolf browser";
    persist = mkEnableOption "Persist state";
    defaultBrowser = mkEnableOption "Set as default browser";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home-manager.users.${username} = {
        programs.librewolf = {
          enable = true;
          settings = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          };
        };
      };

      xdg.mime.defaultApplications = mkIf cfg.defaultBrowser {
        "text/html"                     = [ "librewolf.desktop" ];
        "x-scheme-handler/http"         = [ "librewolf.desktop" ];
        "x-scheme-handler/https"        = [ "librewolf.desktop" ];
      };
    })
    (mkIf cfg.persist {
      home-manager.users.${username}.home.persistence
        ."/persist/home/${username}".directories = [
          ".librewolf"
        ];
    })
  ];
}

