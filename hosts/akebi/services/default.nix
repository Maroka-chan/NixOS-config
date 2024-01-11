{ lib, pkgs, config, ... }:
{
  imports = [
    ./mediamanager
    ./jellyfin
    ./uptime-kuma
    ./tailscale
  ];
}
