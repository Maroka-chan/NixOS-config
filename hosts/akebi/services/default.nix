{ lib, pkgs, config, ... }:
{
  imports = [
    ./transmission
    ./jellyfin
    ./uptime-kuma
  ];
}
