{ lib, pkgs, config, ... }:
{
  imports = [
    ./mediamanager
    ./jellyfin
    ./uptime-kuma
    ./tailscale
    ./samba
    ./restic
  ];
}
