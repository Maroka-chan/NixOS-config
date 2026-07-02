{
  pkgs,
  lib,
  config,
  username,
  ...
}:
with lib; let
  module_name = "thunar";
  cfg = config.configured.programs."${module_name}";
in {
  options.configured.programs."${module_name}" = {
    enable = mkEnableOption "Enable Thunar File Manager";
  };

  config = mkIf cfg.enable {
    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        tumbler
        thunar-archive-plugin
        thunar-media-tags-plugin
        thunar-volman
      ];
    };
    programs.xfconf.enable = true;
    services.gvfs.enable = true;

    environment.systemPackages = with pkgs; [
      ffmpegthumbnailer
    ];

    # Hide Desktop Entries
    home-manager.users.${username} = {
      xdg.desktopEntries = {
        "thunar-bulk-rename" = {
          name = "Bulk Rename";
          noDisplay = true;
        };
        "thunar-settings" = {
          name = "File Manager Settings";
          noDisplay = true;
        };
        "thunar-volman-settings" = {
          name = "Removable Drives and Media";
          noDisplay = true;
        };
      };
    };
  };
}
