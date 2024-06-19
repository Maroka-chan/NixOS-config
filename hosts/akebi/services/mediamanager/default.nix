{ lib, pkgs, config, inputs, ... }:
{
  imports = [
    inputs.shutoku.nixosModule
  ];

  sops.secrets = {
    vpn_privatekey = {};
    vpn_presharedkey = {};
    vpn_allowedips = {};
    vpn_publickey = {};
    vpn_endpoint = {};
    vpn_address = {};
    vpn_dns = {};

    transmission_user = {};
    transmission_pass = {
      owner = "shutoku";
      group = "root";
    };
    tracker_user = {
      owner = "shutoku";
      group = "root";
    };
    tracker_pass = {
      owner = "shutoku";
      group = "root";
    };
    tracker2_user = {
      owner = "shutoku";
      group = "root";
    };
    tracker2_pass = {
      owner = "shutoku";
      group = "root";
    };
  };

  sops.templates."transmission_settings.json".content = ''
    {
      "rpc-username": "${config.sops.placeholder.transmission_user}",
      "rpc-password": "${config.sops.placeholder.transmission_pass}",
      "bind-address-ipv4": "${config.sops.placeholder.vpn_address}"
    }
  '';

  sops.templates."wg0.conf".content = ''
    [Interface]
    PrivateKey = ${config.sops.placeholder.vpn_privatekey}
    Address = ${config.sops.placeholder.vpn_address}
    DNS = ${config.sops.placeholder.vpn_dns}

    [Peer]
    PublicKey = ${config.sops.placeholder.vpn_publickey}
    PresharedKey = ${config.sops.placeholder.vpn_presharedkey}
    AllowedIPs = ${config.sops.placeholder.vpn_allowedips}
    Endpoint = ${config.sops.placeholder.vpn_endpoint}
  '';

  vpnnamespaces.wg = {
    enable = true;
    accessibleFrom = [
      "192.168.0.0/24"
    ];
    wireguardConfigFile = config.sops.templates."wg0.conf".path;
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
    settings = {
      download_dest = "/data/media/downloads";
      media_dest = "/data/media";
      client_addr = "http://192.168.15.1:9091/transmission/rpc";
      client_password_file = config.sops.secrets.transmission_pass.path;
      tracker_username_file = config.sops.secrets.tracker_user.path;
      tracker_password_file = config.sops.secrets.tracker_pass.path;
      tracker2_username_file = config.sops.secrets.tracker2_user.path;
      tracker2_password_file = config.sops.secrets.tracker2_pass.path;
    };
  };
}
