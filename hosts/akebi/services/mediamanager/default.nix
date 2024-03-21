{ lib, pkgs, config, inputs, ... }:
{
  imports = [
    inputs.shutoku.nixosModule
  ];

  sops.secrets = {
    mullvad_privatekey = {};
    mullvad_allowedips = {};
    mullvad_publickey = {};
    mullvad_endpoint = {};
    mullvad_address = {};
    mullvad_dns = {};

    transmission_user = {};
    transmission_pass = {};
  };

  sops.templates."transmission_settings.json".content = ''
    {
      "rpc-username": "${config.sops.placeholder.transmission_user}",
      "rpc-password": "${config.sops.placeholder.transmission_pass}",
      "bind-address-ipv4": "${config.sops.placeholder.mullvad_address}"
    }
  '';

  sops.templates."shutoku_settings.json".content = ''
    {
      "TorrentClient": {
        "Address": "http://192.168.15.1:9091",
        "Username": "${config.sops.placeholder.transmission_user}",
        "Password": "${config.sops.placeholder.transmission_pass}"
      }
    }
  '';

  sops.templates."wg0.conf".content = ''
    [Interface]
    PrivateKey = ${config.sops.placeholder.mullvad_privatekey}
    Address = ${config.sops.placeholder.mullvad_address}
    DNS = ${config.sops.placeholder.mullvad_dns}

    [Peer]
    PublicKey = ${config.sops.placeholder.mullvad_publickey}
    AllowedIPs = ${config.sops.placeholder.mullvad_allowedips}
    Endpoint = ${config.sops.placeholder.mullvad_endpoint}
  '';

  vpnnamespaces.wg = {
    enable = true;
    accessibleFrom = [
      "192.168.0.0/24"
    ];
    wireguardConfigFile = config.sops.templates."wg0.conf".path;
    portMappings = [
      { from = 9091; to = 9091; }
      { from = 5000; to = 5000; }
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
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.transmission_4;
    credentialsFile = config.sops.templates."transmission_settings.json".path;
    settings = {
      "download-dir" = "/data/media/downloads";
      "incomplete-dir" = "/data/media/.incomplete";
      "rpc-bind-address" = "192.168.15.1";
      "rpc-whitelist-enabled" = true;
      "rpc-whitelist" = "192.168.0.*,192.168.15.1,127.0.0.1";
      "rpc-authentication-required" = true;
      "message-level" = 3;

      "blocklist-enabled" = true;
      "blocklist-url" = "https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz";

      "encryption" = 2;
      "utp-enabled" = false;
      "port-forwarding-enabled" = false;

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
    settings = {
      App = {
        DownloadPath = "/data/media/downloads";
        TorrentDestination = "/data/media";
      };
    };
    torrentClientCredentialsFile = config.sops.templates."shutoku_settings.json".path;
  };
}
