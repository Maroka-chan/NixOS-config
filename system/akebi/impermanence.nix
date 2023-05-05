{ config, pkgs, ... }:
{
    # State to persist.
    environment.persistence."/persist" = {
        directories = [ ];
        files = [
            "/etc/machine-id"
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"
        ];
    };
}