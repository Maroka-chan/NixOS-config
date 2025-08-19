{ pkgs, lib, config, username, inputs, ... }:
with lib;
let
  module_name = "vscodium";
  cfg = config.configured.programs."${module_name}";
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable Microsoft Free Visual Studio Code Editor";
  };
  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      inputs.nix-vscode-extensions.overlays.default
    ];
    home-manager.users.${username} = {
      programs.vscode = {
        enable = true;
        mutableExtensionsDir = false;
        package = pkgs.vscodium;
        profiles.default = {
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;
          extensions = with (pkgs.forVSCodeVersion "${pkgs.vscodium.version}").open-vsx; [
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
            "workbench.iconTheme" = "Monokai Pro (Filter Spectrum) Icons";
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

