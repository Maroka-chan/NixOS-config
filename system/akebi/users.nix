{ config, pkgs, ... }:
let
    deployment_user = "deploy";
in
{
    users.mutableUsers = false;

    users.users."${deployment_user}" = {
        # isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDe1OWBkEGP8kd4nJz280NaPLGVTyBj1IW6uvcLaNoDM2wM+i7hKKisYJCOdOxrkFxS0I0XoX88MPN0axel4jvmXNUHy/czi3TJTG6mLufxFF+UMcooJWHaExwfJSkYx+2/Ufk8bYbB0PJ3eLvpwRBywt4Qv9HrSLI1kFJfPSh+03IcIXz3+RJ7mz37j8Li2DTeWbRkZ9OJrUeT+ciKdnGK6p+2PotC2uWijhbXOENwy0Huu80WYIypOdwBcRQRAFE6G2OLX8rj7TqOj01tRSrrvjq9XUR+xlK6VCo2HY3b7NHve9j1kRgsHI2h99yiRWEJ1PXSU8aicIVY4qWgYowyYFT14XjD5aKeO5KHb6ULXcDHm4QteEuAr7vTROPM0nX/fF6UkeHJ9M1OyOGxIwIHsxpoERohH5sY4cXo4hKPn1P476YsLi765Smn2awCzFV89k0GFOYNX27gAniuMQTpPSSgTfFnNMzUVVdFRMwv82WvonkmkmwJ/+u6NAX/P0k=" ];
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