{ config, pkgs, ... }:
{
    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.supportedFilesystems = [ "btrfs" ];
    hardware.enableAllFirmware = true;
}