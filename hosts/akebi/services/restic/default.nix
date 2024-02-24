{ pkgs, config, ... }:
{
  sops.secrets = {
    restic_pass = {};
    restic_memories_repo = {};
    restic_access_key_id = {};
    restic_secret_access_key = {};
  };

  sops.templates."restic.env".content = ''
    AWS_ACCESS_KEY_ID=${config.sops.placeholder.restic_access_key_id}
    AWS_SECRET_ACCESS_KEY=${config.sops.placeholder.restic_secret_access_key}
  '';

  services.restic = {
    backups = {
      memories = {
        # user = "backup";
        initialize = true;
        repositoryFile = config.sops.secrets.restic_memories_repo.path;
        passwordFile = config.sops.secrets.restic_pass.path;
        environmentFile = config.sops.templates."restic.env".path;
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
