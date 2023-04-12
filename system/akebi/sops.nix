{ config, pkgs, ... }:
let
    secrets_path = /persist/var/lib/sops/.secrets;
in
{
    sops.defaultSopsFile = secrets_path + "/akebi.yaml";
    sops.age.sshKeyPaths = [];
    sops.age.keyFile = "/persist/var/lib/sops/keys.txt";
    sops.gnupg.sshKeyPaths = [];

    sops.secrets.maroka-password = {
        neededForUsers = true;
    };
}