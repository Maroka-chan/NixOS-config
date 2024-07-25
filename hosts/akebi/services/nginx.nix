{ pkgs, config, ... }:
{
  services.nginx.enable = true;
  services.nginx.group = "media";
  services.nginx.virtualHosts."_" = {
    root = "/data/media";
    locations = {
      "/" = {
        extraConfig = "autoindex on;";
        tryFiles = "$uri/ $uri =404";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}

