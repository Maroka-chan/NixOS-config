{ config, pkgs, ... }:
{
    # Firewall
    networking.firewall = {
        enable = true;
        allowPing = false;
        allowedTCPPorts = [ ];
    };
}