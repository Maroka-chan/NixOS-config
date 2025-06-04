{ lib, pkgs, config, ... }:
{
  imports = [
    ./mediamanager
    ./jellyfin
    ./tailscale
    ./samba
    ./restic
    ./home-assistant.nix
  ];
}
