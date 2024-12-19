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

  # Metrics Monitoring
  services.prometheus = {
    enable = true;
    port = 9001;
  };

  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [ "systemd" "processes" ];
    port = 9002;
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "node";
      static_configs = [{
        targets = [ "127.0.0.1:9002" ];
      }];
    }
  ];

  services.grafana = {
    enable = true;
    settings.server = {
      http_port = 3002;
      http_addr = "0.0.0.0";
    };
  };
  networking.firewall.allowedTCPPorts = [ 3002 ];
}
