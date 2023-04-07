{ config, lib, pkgs, ... }:
{
    fileSystems = {
        "/" = {
            device  = "/dev/disk/by-label/NIXOS";
            fsType  = "btrfs";
            options = [ "noatime" "compress=zstd" "autodefrag" "ssd" "space_cache" "subvol=root" ];
        };
        "/home" = {
            device  = "/dev/disk/by-label/NIXOS";
            fsType  = "btrfs";
            options = [ "noatime" "compress=zstd" "autodefrag" "ssd" "space_cache" "subvol=home" ];
        };
        "/nix" = {
            device  = "/dev/disk/by-label/NIXOS";
            fsType  = "btrfs";
            options = [ "noatime" "compress=zstd" "autodefrag" "ssd" "space_cache" "subvol=nix" ];
        };
        "/persist" = {
            device  = "/dev/disk/by-label/NIXOS";
            fsType  = "btrfs";
            options = [ "noatime" "compress=zstd" "autodefrag" "ssd" "space_cache" "subvol=persist" ];
            neededForBoot = true;
        };
        "/var/log" = {
            device  = "/dev/disk/by-label/NIXOS";
            fsType  = "btrfs";
            options = [ "noatime" "compress=zstd" "autodefrag" "ssd" "space_cache" "subvol=log" ];
            neededForBoot = true;
        };
        "/data" = {
            device  = "/dev/disk/by-label/DATA";
            fsType  = "btrfs";
            options = [ "noatime" "compress=zstd" "autodefrag" "space_cache" "subvol=data" ];
        };
    };
}
