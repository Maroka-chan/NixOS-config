{ lib, pkgs, config, inputs, ... }:
{
  imports = [
    inputs.yuttari.nixosModule
  ];

  services.yuttari = {
    enable = true;
    group = "media";
    openFirewall = true;
  };
}

