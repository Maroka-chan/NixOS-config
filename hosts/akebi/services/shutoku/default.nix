{ lib, pkgs, config, ... }:
{
  sops.secrets.transmission_user = {};
  sops.secrets.transmission_pass = {};

  users.groups.media = {};

  sops.templates."shutoku_settings.json".content = ''
    {
      "TorrentClient": {
        "Address": "http://192.168.15.1:9091",
        "Username": "${config.sops.placeholder.transmission_user}",
        "Password": "${config.sops.placeholder.transmission_pass}"
      }
    }
  '';

  systemd.services.shutoku = {
    bindsTo = [ "netns@wg.service" ];
    requires = [ "network-online.target" ];
    after = [ "wg.service" ];
    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/wg";
    };
  };

  services.vpnnamespace.portMappings = [{
    From = 5000;
    To = 5000;
  }];

  services.shutoku = {
    enable = true;
    group = "media";
    settings = {
      App = {
        DownloadPath = "/data/media/downloads";
        TorrentDestination = "/data/media";
      };
    };
    torrentClientCredentialsFile = config.sops.templates."shutoku_settings.json".path;
    openFirewall = true;
  };
}
