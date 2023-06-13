{ config, pkgs, ... }:
{
    networking.firewall = {
        enable = true;
        allowPing = false;
    };
}