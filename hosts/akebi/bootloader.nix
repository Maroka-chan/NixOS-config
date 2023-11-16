{ config, pkgs, ... }:
{
    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.supportedFilesystems = [ "btrfs" ];
    hardware.enableAllFirmware = true;

    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;
}
