{ pkgs, lib, config, username, ... }:
with lib;
let
  module_name = "firefox";
  cfg = config.configured.programs."${module_name}";

  userChrome = pkgs.stdenvNoCC.mkDerivation {
    name = "userChrome";

    src = builtins.fetchurl {
      url = "https://github.com/Tagggar/Firefox-Alpha/raw/refs/heads/main/chrome/userChrome.css";
      sha256 = "sha256:1bw5szkqxdmkr2lpmaxz0z7rkbwm87n64b6ihgvrw5w8jqcr0hxq";
    };

    unpackPhase = ''
      cp $src ./userChrome.css
    '';

    patchFlags = [ "-p0" ];
    patches = [ ./userChrome.patch ];

    dontConfigure = true;
    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      cp ./userChrome.css $out
    '';
  };
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable the Firefox browser";
    persist = mkEnableOption "Persist state";
    defaultBrowser = mkEnableOption "Set as default browser";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home-manager.users.${username} = {
        programs.firefox = {
          enable = true;
          profiles.profile_0 = {
            id = 0;
            name = "profile_0";
            isDefault = true;
            userChrome = readFile userChrome;
            settings = {
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "browser.urlbar.maxRichResults" = 0;
              "browser.urlbar.clickSelectsAll" = true;
              "extensions.autoDisableScopes" = 0; # Automatically enable extensions
            };
            extensions = with pkgs.nur.repos.rycee.firefox-addons; [
              bitwarden
              ublock-origin
              adaptive-tab-bar-colour
            ];
          };
        };
      };

      xdg.mime.defaultApplications = mkIf cfg.defaultBrowser {
        "text/html"                     = [ "firefox.desktop" ];
        "x-scheme-handler/http"         = [ "firefox.desktop" ];
        "x-scheme-handler/https"        = [ "firefox.desktop" ];
      };
    })
    (mkIf cfg.persist {
      home-manager.users.${username}.home.persistence
        ."/persist/home/${username}".directories = [
          ".firefox"
        ];
    })
  ];
}
  
