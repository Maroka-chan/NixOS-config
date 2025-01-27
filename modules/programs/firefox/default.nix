{ pkgs, lib, config, username, ... }:
with lib;
let
  module_name = "firefox";
  cfg = config.configured.programs."${module_name}";

  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  #userChrome = pkgs.stdenvNoCC.mkDerivation {
  #  name = "userChrome";

  #  src = builtins.fetchurl {
  #    url = "https://github.com/Tagggar/Firefox-Alpha/raw/refs/heads/main/chrome/userChrome.css";
  #    sha256 = "sha256:1bw5szkqxdmkr2lpmaxz0z7rkbwm87n64b6ihgvrw5w8jqcr0hxq";
  #  };

  #  unpackPhase = ''
  #    cp $src ./userChrome.css
  #  '';

  #  patchFlags = [ "-p0" ];
  #  patches = [ ./userChrome.patch ];

  #  dontConfigure = true;
  #  dontBuild = true;
  #  dontFixup = true;

  #  installPhase = ''
  #    cp ./userChrome.css $out
  #  '';
  #};

  userChrome = ./userChrome.css;
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable the Firefox browser";
    defaultBrowser = mkEnableOption "Set as default browser";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home-manager.users.${username} = let
        hmConfig = config.home-manager.users.${username};
        profilesPath = let
          configPath = hmConfig.programs.firefox.configPath;
        in if isDarwin then "${configPath}/Profiles" else configPath;
      in {
        programs.firefox = {
          enable = true;

          profiles.profile_0 = {
            id = 0;
            name = "profile_0";
            isDefault = true;
            userChrome = readFile userChrome;
            settings = {
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "browser.urlbar.clickSelectsAll" = true;
              "extensions.autoDisableScopes" = 0; # Automatically enable extensions

              # Arkenfox user-overrides

              ## Enable Session Restore
              "browser.startup.page" = 3; # (resume previous session)
              "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = false;

              ## Keep Cookies
              "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;

              ## Disable GMP (Gecko Media Plugins)
              "media.gmp-provider.enabled" = false;

              ## Resist Fingerprinting
              "privacy.resistFingerprinting" = true;

              ## Spoofing
              "privacy.spoof_english" = 2; # (enabled)

              ## Optional Section (5000's)
              "signon.rememberSignons" = false;
              "webgl.disabled" = true;

              ### Only give one history suggestion for autocompletion
              "browser.urlbar.maxRichResults" = 1;

              ### Disable form autofill
              "extensions.formautofill.addresses.enabled" = false;
              "extensions.formautofill.creditCards.enabled" = false;
            };
            extensions = with pkgs.nur.repos.rycee.firefox-addons; [
              bitwarden
              ublock-origin
              adaptive-tab-bar-colour
            ];
          };
        };

        # Arkenfox
        home.file = mkMerge (flip mapAttrsToList hmConfig.programs.firefox.profiles (_: profile: {
          "${profilesPath}/${profile.path}/user.js".text = readFile (builtins.fetchurl {
            url = "https://github.com/arkenfox/user.js/raw/refs/heads/master/user.js";
            sha256 = "sha256:0rpi1z2xq6fbak3bxx32mavggvwi4l9wnzghl2ri641ahvdhgxxc";
          });
        }));

        # TODO: prefs.js is a runtime file. It contains settings, but also ID's, counters etc. and extensions might choose to store data there.
        # Do we care about this data, or should we just delete prefs.js when updating?
        # Alternatively we can run the Arkenfox prefsCleaner. This should be done while firefox is closed.
        # Is there a way to check if firefox is closed when updating with Nix?
        # Otherwise we can just run prefsCleaner manually after an update.
        # Can we add a warning with Nix to run prefsCleaner when Arkenfox is updated?
        # Maybe in postFetch?
        # Home-manager has the ability to set hooks when creating a file with home.file etc.
        # Maybe have a hook that runs prefsCleaner when home-manager writes user.js?

      };

      xdg.mime.defaultApplications = mkIf cfg.defaultBrowser {
        "text/html"                     = [ "firefox.desktop" ];
        "x-scheme-handler/http"         = [ "firefox.desktop" ];
        "x-scheme-handler/https"        = [ "firefox.desktop" ];
      };
    })
    (mkIf config.impermanence.enable {
      home-manager.users.${username}.home.persistence
        ."/persist/home/${username}".directories = [
          ".mozilla/firefox"
        ];
    })
  ];
}
  
