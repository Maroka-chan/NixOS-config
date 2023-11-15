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
        { from = "host"; host.port = 9091; guest.port = 9091; }
        { from = "host"; host.port = 3001; guest.port = 3001; }
      ];
    };
  };

  users.users.vmuser = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "vmuser";
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqzG8P89pW2HiMb7zfJgp22t968eHuOsheYEHtuhshl aisaka" ];
  };


  services.vpnnamespace = {
    accessibleFrom = [
      "10.0.2.0/24"
    ];
  };
}
