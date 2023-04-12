{ config, pkgs, ... }:
{
    # Firewall
    networking.firewall = {
        enable = true;
        allowPing = false;
        allowedTCPPorts = [
            22          # SSH
            8096 8920   # Jellyfin
        ];
    };
}