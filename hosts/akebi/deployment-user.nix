{ config, pkgs, ... }:
let
    deployment_user = "deploy";
in
{
    users.users."${deployment_user}" = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqzG8P89pW2HiMb7zfJgp22t968eHuOsheYEHtuhshl aisaka"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDyMZKyptGPtS/osbdmDrhnn2J08Iiy/i+BrvqvyNBpJ kanan"
        ];
        packages = with pkgs; [];
    };

    # Allow the deployment user to run any command as root without a password
    security.sudo.extraRules = [
        {
            users = [ "${deployment_user}" ];
            commands = [ 
                {
                    command = "ALL";
                    options = [ "SETENV" "NOPASSWD" ];
                }
            ];
        }
    ];
}
