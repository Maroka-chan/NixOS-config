{ inputs, config, lib, username, ... }: let
  module_name = "home-manager";
  cfg = config."${module_name}";
  inherit (lib) mkEnableOption mkIf;
in {
  options."${module_name}" = {
    enable = mkEnableOption "Enable home-manager";
  };

  config = mkIf cfg.enable {
    programs.fuse.userAllowOther = true;

    home-manager = {
      extraSpecialArgs = { inherit inputs username; };
      useGlobalPkgs = true;
      useUserPackages = true;
    };

    home-manager.users."${username}" = {
      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;

      # This value determines the Home Manager release that your
      # configuration is compatible with. This helps avoid breakage
      # when a new Home Manager release introduces backwards
      # incompatible changes.
      #
      # You can update Home Manager without changing this value. See
      # the Home Manager release notes for a list of state version
      # changes in each release.
      home.stateVersion = "23.11";
    };
  };
}
