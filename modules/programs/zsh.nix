{ pkgs, lib, config, username, ... }:
with lib;
let
  module_name = "zsh";
  cfg = config.configured.programs."${module_name}";
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable zsh Terminal Emulator";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.zsh.enable = true;
      environment.pathsToLink = [ "/share/zsh" ]; # Needed for zsh completion for system packages
      users.defaultUserShell = pkgs.zsh;

      home-manager.users.${username} = {
        programs.zsh = {
          enable = true;
          autosuggestion.enable = true;
          enableCompletion = true;
          syntaxHighlighting.enable = true;

          history = {
            size = 10000;
            path = "/persist/home/${username}/.local/share/zsh/.zsh_history";
          };
        };

        programs.starship.enable = true;
        programs.starship.enableZshIntegration = true;
        programs.starship.enableTransience = true;
      };
    })
    (mkIf config.impermanence.enable {
      home-manager.users.${username}.home.persistence
      ."/persist/home/${username}".files = [
        ".p10k.zsh"
      ];
    })
  ];
}


