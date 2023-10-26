{ lib, pkgs, config, ... }:
let
  wireguardAddress = "10.67.170.174/32";
in {
  services.vpnnamespace = {
    enable = true;
    accessibleFrom = [
      "10.0.2.0/24"
      "192.168.0.24"
    ];
    inherit wireguardAddress;
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
    openRPCPort = true;
    settings = {
      "bind-address-ipv4" = wireguardAddress;
      "rpc-bind-address" = "0.0.0.0";
      "rpc-whitelist-enabled" = false;
    };
  };
}
