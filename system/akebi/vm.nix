{ config, pkgs, ... }:
{
    virtualisation.vmVariant = {
        virtualisation = {
            cores = 4;
            memorySize = 8192;
            diskSize = 20480; # 20 GB
            forwardPorts = [
                { from = "host"; host.port = 2222; guest.port = 22; }
                { from = "host"; host.port = 8096; guest.port = 8096; }
                { from = "host"; host.port = 8920; guest.port = 8920; }
            ];
        };
    };

    users.users.vmuser = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        password = "vmuser";
    };
}