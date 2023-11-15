{ pkgs, config, ... }:
{
  services.restic = {
    server.enable = true;
    backups = {
      
    };
  };
}
