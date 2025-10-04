{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [
  ];

  services.home-assistant = {
    enable = true;
    #openFirewall = true;
    #configWritable = true;
    config = null;
    configDir = "/etc/home-assistant";
    lovelaceConfig = null;
    extraComponents = [
      "esphome"
      "ssdp"
      "dhcp"
      "stream"
      "go2rtc"
      "met"
      "radio_browser"
      "mobile_app"
      "default_config"
    ];
    extraPackages =
      python3Packages: with python3Packages; [
        numpy
      ];

    #config = {
    #  homeassistant = {
    #    name = "Home";
    #    unit_system = "metric";
    #    time_zone = "UTC";
    #  };
    #  http = {};
    #  default_config = {};
    #};
  };
  networking.firewall.allowedTCPPorts = [
    8123
  ];

  environment.persistence."/persist" = {
    directories = [
      "/etc/home-assistant"
    ];
  };
}
