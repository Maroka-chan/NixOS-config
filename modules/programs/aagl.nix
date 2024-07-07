{ lib, config, username, inputs, ... }:
with lib;
let
  module_name = "aagl";
  cfg = config.configured.programs."${module_name}";
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable An Anime Game Launcher";
    persist = mkEnableOption "Persist state";
  };

  imports = [ inputs.aagl.nixosModules.default ];

  config = mkMerge [
    (mkIf cfg.enable {
      nix.settings = inputs.aagl.nixConfig;
      programs.anime-game-launcher.enable = true;
      programs.honkers-railway-launcher.enable = true;
      programs.sleepy-launcher.enable = true;
    })
    (mkIf cfg.persist {
      home-manager.users.${username}.home.persistence
      ."/persist/home/${username}".directories = [
        ".local/share/anime-game-launcher"
        ".local/share/honkers-railway-launcher"
        ".local/share/sleepy-launcher"
      ];
    })
  ];
}
