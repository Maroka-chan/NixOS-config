# User to use with sshfs
{ config, pkgs, ... }:
{
    users.users.sshfs = {
        isNormalUser = true;
        extraGroups = [ ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMLXkO6gEHyTSm+CJuhWPQRMJTM7psG2JzBROSTbK8op maroka@Arch-Desktop"
        ];
        packages = with pkgs; [];
    };
}
