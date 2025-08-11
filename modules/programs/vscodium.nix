{ pkgs, lib, config, username, ... }:
with lib;
let
  module_name = "vscodium";
  custom-extensions = import ./open-vsx.nix { inherit pkgs lib; };
  cfg = config.configured.programs."${module_name}";
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable Microsoft Free Visual Studio Code Editor";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.vscode = {
        enable = true;
        mutableExtensionsDir = false;
        package = pkgs.vscodium;
        profiles.default = {
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;
          extensions = with pkgs.vscode-extensions; with custom-extensions; [
            jnoortheen.nix-ide
            rust-lang.rust-analyzer
            detachhead.basedpyright
            mads-hartmann.bash-ide-vscode
            monokai.theme-monokai-pro-vscode
            arrterian.nix-env-selector
          ];
          userSettings = {
            "telemetry.telemetryLevel" = "off";
            "telemetry.feedback.enabled" = false;
            "workbench.enableExperiments" = false;
            "workbench.settings.enableNaturalLanguageSearch" = false;
            "workbench.welcomePage.extraAnnouncements" = false;
            "workbench.colorTheme" = "Monokai Pro (Filter Spectrum)";
            "window.menuBarVisibility" = "compact";
            "window.customTitleBarVisibility" = "never";
            "window.menuStyle" = "custom";
            "window.titleBarStyle" = "native";
            "editor.fontFamily" = "'CaskaydiaCove Nerd Font', 'Droid Sans Mono', 'monospace', monospace";
            "nixEnvSelector.useFlakes" = true;
          };
        };
      };
    };
  };
}

