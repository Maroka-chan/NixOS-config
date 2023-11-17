{ lib, pkgs, config, ... }:
{
  sops.secrets = {
    mullvad_privatekey = {};
    mullvad_publickey = {};
    mullvad_endpoint = {};
    mullvad_address = {};

    transmission_user = {};
    transmission_pass = {};
  };

  sops.templates."wg0.conf".content = ''
    [Interface]
    PrivateKey = ${config.sops.placeholder.mullvad_privatekey}

    [Peer]
    PublicKey = ${config.sops.placeholder.mullvad_publickey}
    AllowedIPs = 0.0.0.0/0,::0/0
    Endpoint = ${config.sops.placeholder.mullvad_endpoint}
  '';

  sops.templates."transmission_settings.json".content = ''
    {
      "rpc-username": "${config.sops.placeholder.transmission_user}",
      "rpc-password": "${config.sops.placeholder.transmission_pass}",
      "bind-address-ipv4": "${config.sops.placeholder.mullvad_address}"
    }
  '';

  services.vpnnamespace = {
    enable = true;
    accessibleFrom = [
      "192.168.0.0/24"
    ];
    wireguardAddressPath = config.sops.secrets.mullvad_address.path;
    wireguardConfigFile = config.sops.templates."wg0.conf".path;
    portMappings = [{
      From = 9091;
      To = 9091;
    }];
  };

  systemd.services.transmission = {
    bindsTo = [ "netns@wg.service" ];
    requires = [ "network-online.target" ];
    after = [ "wg.service" ];
    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/wg";
    };
  };

  services.transmission = {
    enable = true;
    package = pkgs.unstable.transmission_4;
    openRPCPort = true;
    credentialsFile = config.sops.templates."transmission_settings.json".path;
    settings = {
      "rpc-bind-address" = config.services.vpnnamespace.namespaceAddress;
      "rpc-whitelist-enabled" = true;
      "rpc-whitelist" = "192.168.0.*";
      "rpc-authentication-required" = true;

      "blocklist-enabled" = true;
      "blocklist-url" = "https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz";

      "encryption" = 2;
      "utp-enabled" = false;
      "port-forwarding-enabled" = false;

      "anti-brute-force-enabled" = true;
      "anti-brute-force-threshold" = 10;
    };
  };
}
