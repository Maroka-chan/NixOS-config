{ lib, pkgs, config, inputs, ... }:
{
  sops.secrets = {
    mullvad_privatekey = {};
    mullvad_publickey = {};
    mullvad_endpoint = {};
    mullvad_address = {};

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

    [Peer]
    PublicKey = ${config.sops.placeholder.mullvad_publickey}
    AllowedIPs = 0.0.0.0/0,::0/0
    Endpoint = ${config.sops.placeholder.mullvad_endpoint}
  '';

  services.vpnnamespace = {
    enable = true;
    accessibleFrom = [
      "192.168.0.0/24"
    ];
    wireguardAddressPath = config.sops.secrets.mullvad_address.path;
    wireguardConfigFile = config.sops.templates."wg0.conf".path;
    portMappings = [
      { From = 9091; To = 9091; }
      { From = 5000; To = 5000; }
    ];
  };

  systemd.services."container@mediamanager" = {
    requires = [ "wg.service" ];
  };

  containers.mediamanager = {
    autoStart = true;
    ephemeral = true;
    extraFlags = [ "--network-namespace-path=/var/run/netns/wg" ];

    bindMounts = {
      "${config.sops.templates."transmission_settings.json".path}".isReadOnly = true;
      "${config.sops.templates."shutoku_settings.json".path}".isReadOnly = true;
      "/data/media".isReadOnly = false;
    };

    config = {
      imports = [
        inputs.shutoku.nixosModule
      ];

      users.groups.media = {};

      networking.nameservers = [ "100.64.0.23" ];

      systemd.services.transmission.serviceConfig = {
        RootDirectoryStartOnly = lib.mkForce false;
        RootDirectory = lib.mkForce "";
      };

      services.transmission = {
        enable = true;
        group = "media";
        package = inputs.nixpkgs.legacyPackages.${pkgs.system}.transmission_4;
        openRPCPort = true;
        credentialsFile = config.sops.templates."transmission_settings.json".path;
        settings = {
          "download-dir" = "/data/media/downloads";
          "incomplete-dir" = "/data/media/.incomplete";
          "rpc-bind-address" = "192.168.15.1";
          "rpc-whitelist-enabled" = true;
          "rpc-whitelist" = "192.168.0.*,192.168.15.1,127.0.0.1";
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

      system.stateVersion = "23.11";

      networking = {
        firewall = {
          enable = true;
          allowedUDPPorts = [ 51820 ];
        };

        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;
    };
  };
}
