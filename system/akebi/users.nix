{ config, pkgs, ... }:
{
    users.mutableUsers = false;

    users.users.maroka = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        passwordFile = config.sops.secrets.maroka-password.path;
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMLXkO6gEHyTSm+CJuhWPQRMJTM7psG2JzBROSTbK8op maroka@Arch-Desktop" ];
        packages = with pkgs; [];
    };
}