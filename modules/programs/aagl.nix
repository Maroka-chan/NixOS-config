{ lib, config, username, inputs, ... }:
with lib;
let
  module_name = "aagl";
  cfg = config.programs."${module_name}";
in {
  options.programs."${module_name}" = {
    enable = mkEnableOption "Enable An Anime Game Launcher";
    persist = mkEnableOption "Persist state";
  };

  imports = [ inputs.aagl.nixosModules.default ];

  config = mkMerge [
    (mkIf cfg.enable {
      programs.anime-game-launcher.enable = true;
      nix.settings = inputs.aagl.nixConfig;
    })
    (mkIf cfg.persist {
      home-manager.users.${username}.home.persistence
      ."/persist/home/${username}".directories = [
        ".local/share/anime-game-launcher"
      ];
    })
  ];
}
