{ pkgs, config, ... }:
{
  services.samba = {
    enable = true;
    openFirewall = true;
  };
}
