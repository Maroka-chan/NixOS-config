{ config, ... }:
{
  age.secrets.restic-env.file = ../../../../secrets/restic-env.age;
  age.secrets.restic-pass.file = ../../../../secrets/restic-pass.age;
  age.secrets.restic-repo.file = ../../../../secrets/restic-repo.age;

  services.restic = {
    backups = {
      memories = {
        initialize = true;
        repositoryFile = config.age.secrets.restic-repo.path;
        passwordFile = config.age.secrets.restic-pass.path;
        environmentFile = config.age.secrets.restic-env.path;
        paths = [
          "/data/networkshare/Pictures/Memories"
          "/data/networkshare/Pictures/Projects"
          "/data/networkshare/Pictures/Screenshots"
          "/data/networkshare/Pictures/Anime"
          "/data/networkshare/Videos/Memories"
          "/data/networkshare/Documents"
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
