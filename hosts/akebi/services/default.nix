{ lib, pkgs, config, ... }:
{
  imports = [
    ./transmission
    ./jellyfin
    ./shutoku
    ./uptime-kuma
    ./tailscale
  ];
}
