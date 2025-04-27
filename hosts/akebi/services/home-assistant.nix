{ lib, pkgs, config, inputs, ... }:
{
  imports = [
  ];

  services.home-assistant = {
    enable = true;
    openFirewall = true;
    configWritable = true;
  };
}


