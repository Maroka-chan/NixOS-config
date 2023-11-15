{ pkgs, config, ... }:
{
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "0.0.0.0";
      PORT = "3001";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      3001
    ];
  };
}
