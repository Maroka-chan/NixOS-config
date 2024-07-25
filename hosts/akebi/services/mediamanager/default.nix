{ pkgs, config, inputs, ... }:
{
  imports = [
    inputs.shutoku.nixosModule
  ];

  age.secrets.transmission-settings.file = ../../../../secrets/transmission-settings.age;
  age.secrets.vpn-wireguard.file = ../../../../secrets/vpn-wireguard.age;
  age.secrets.shutoku-settings.file = ../../../../secrets/shutoku-settings.age;

  vpnnamespaces.wg = {
    enable = true;
    accessibleFrom = [
      "192.168.1.0/24"
    ];
    wireguardConfigFile = config.age.secrets.vpn-wireguard.path;
    portMappings = [
      { from = 9091; to = 9091; }
      { from = 3000; to = 3000; }
    ];
    openVPNPorts = [
      { port = 12340; protocol = "both"; }
    ];
  };

  users.groups.media = {};

  systemd.services.transmission = {
    vpnconfinement = {
      enable = true;
      vpnnamespace = "wg";
    };
  };

  services.transmission = {
    enable = true;
    group = "media";
    package = pkgs.transmission_4;
    credentialsFile = config.age.secrets.transmission-settings.path;
    settings = {
      "download-dir" = "/data/media/downloads";
      "incomplete-dir" = "/data/media/.incomplete";
      "rpc-bind-address" = "192.168.15.1";
      "rpc-whitelist-enabled" = true;
      "rpc-whitelist" = "192.168.1.*,192.168.15.1,127.0.0.1";
      "rpc-authentication-required" = true;
      "message-level" = 3;

      "blocklist-enabled" = true;
      "blocklist-url" = "https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz";

      "encryption" = 2;
      "pex-enabled" = false;
      "dht-enabled" = false;
      "lpd-enabled" = false;
      "utp-enabled" = false;

      "port-forwarding-enabled" = true;
      "peer-port" = 12340;

      "cache-size-mb" = 512;
      "peer-limit-global" = 1000;
      "peer-limit-per-torrent" = 200;

      "anti-brute-force-enabled" = true;
      "anti-brute-force-threshold" = 10;
    };
  };

  systemd.services.shutoku.vpnconfinement = {
    enable = true;
    vpnnamespace = "wg";
  };

  services.shutoku = {
    enable = true;
    group = "media";
    listenAddr = "192.168.15.1:3000";
    settingsFile = config.age.secrets.shutoku-settings.path;
  };
}
