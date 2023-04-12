{ config, pkgs, ... }:
let
    impermanence = builtins.fetchTarball {
        url = "https://github.com/nix-community/impermanence/archive/master.tar.gz";
        sha256 = "0hpp8y80q688mvnq8bhvksgjb6drkss5ir4chcyyww34yax77z0l";
    };
in
{
    imports = [ "${impermanence}/nixos.nix" ];

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