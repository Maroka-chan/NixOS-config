{ lib, pkgs, config, ... }:
{
  imports = [
    ./mediamanager
    ./jellyfin
    ./tailscale
    ./samba
    ./restic
  ];
}
