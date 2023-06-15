{ config, pkgs, ... }:
{
    environment.persistence."/nix/persist" = {
        directories = [
            "/etc/nixos"
            "/etc/NetworkManager"
            "/var/log"
            "/var/lib"
        ];
        files = [
            "/etc/machine-id"
            "/etc/nix/id_rsa"
        ];
    };
}