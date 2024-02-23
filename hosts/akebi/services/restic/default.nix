{ pkgs, config, ... }:
{
  services.restic = {
    backups = {
      memories = {
        repository = "";
        initialize = true;
        passwordFile = "";
        paths = [
          "/data/networkshare/Pictures/Memories"
          "/data/networkshare/Videos/Memories"
        ];
        timerConfig = {
          OnCalendar = "00:05";
          Persistent = true;
          RandomizedDelaySec = "5h";
        };
      };
    };
  };
}
