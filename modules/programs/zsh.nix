{ lib, config, username, ... }:
with lib;
let
  module_name = "zsh";
  cfg = config.configured.programs."${module_name}";
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable zsh Terminal Emulator";
    persist = mkEnableOption "Persist state";
  };

  config = mkMerge [
    (mkIf cfg.enable {
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

          initExtraFirst = ''
            # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
            # Initialization code that may require console input (password prompts, [y/n]
            # confirmations, etc.) must go above this block; everything else may go below.
            if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
              source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
            fi

          '';

          initExtra = ''
            # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
            [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
          '';

          zplug = {
            enable = true;
            plugins = [
              { name = "romkatv/powerlevel10k"; tags = [ "as:theme" "depth:1" ]; }
            ];
          };
        };
      };
    })
    (mkIf cfg.persist {
      home-manager.users.${username}.home.persistence
      ."/persist/home/${username}".files = [
        ".p10k.zsh"
      ];
    })
  ];
}


