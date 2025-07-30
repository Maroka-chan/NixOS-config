{ pkgs, lib, config, username, ... }:
with lib;
let
  module_name = "vscode";
  custom-extensions = import ./vscode-extensions.nix { inherit pkgs lib; };
  cfg = config.configured.programs."${module_name}";
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable Visual Studio Code Editor";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.vscode = {
        enable = true;
        mutableExtensionsDir = false;
        profiles.default = {
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;
          extensions = with pkgs.vscode-extensions; with custom-extensions; [
            jnoortheen.nix-ide
            rust-lang.rust-analyzer
            ms-python.python
            mads-hartmann.bash-ide-vscode
            github.copilot
            lakshits11.monokai-pirokai
            arrterian.nix-env-selector
          ];
          userSettings = {
            "editor.fontFamily" = "'CaskaydiaCove Nerd Font', 'Droid Sans Mono', 'monospace', monospace";
            "nixEnvSelector.useFlakes" = true;
          };
        };
      };
    };
  };
}
