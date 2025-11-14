{
  pkgs,
  lib,
  config,
  username,
  inputs,
  ...
}:
with lib;
let
  module_name = "vscode";
  cfg = config.configured.programs."${module_name}";
in
{
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable Visual Studio Code Editor";
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      inputs.nix4vscode.overlays.default
    ];
    home-manager.users.${username} = {
      programs.vscode = {
        enable = true;
        mutableExtensionsDir = false;
        profiles.default = {
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;
          extensions = pkgs.nix4vscode.forVscodeVersion "${pkgs.vscode.version}" [
            "github.copilot"
            "github.copilot-chat"
            "ms-python.python"
            "jnoortheen.nix-ide"
            "rust-lang.rust-analyzer"
            "mads-hartmann.bash-ide-vscode"
            "monokai.theme-monokai-pro-vscode"
            "arrterian.nix-env-selector"
            "ms-vscode-remote.remote-ssh"
            "yocto-project.yocto-bitbake"
          ];
          userSettings = {
            "editor.fontFamily" = "'CaskaydiaCove Nerd Font', 'Droid Sans Mono', 'monospace', monospace";
            "nixEnvSelector.useFlakes" = true;
            "github.copilot.nextEditSuggestions.enabled" = true;
            "files.watcherExclude" = {
              "build/sstate-cache/**" = true;
              "build/downloads/**" = true;
              "build/tmp/**" = true;
            };
            "search.exclude" = {
              "build/sstate-cache/**" = true;
              "build/downloads/**" = true;
              "build/tmp/**" = true;
            };
            "files.exclude" = {
              "build/sstate-cache/**" = true;
              "build/downloads/**" = true;
              "build/tmp/**" = true;
            };
          };
        };
      };
    };
  };
}
