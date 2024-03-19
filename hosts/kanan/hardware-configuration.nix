{ config, lib, pkgs, modulesPath, ... }:
{
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "usb_storage" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices.crypt-nixos.keyFile = "/dev/disk/by-partlabel/CRYPTKEY";
  boot.initrd.luks.devices.crypt-nixos.preLVM = false;
  boot.initrd.luks.devices = 
  let 
    crypt-template = {
      allowDiscards = true;
      keyFileSize = 4096;
      keyFile = "/dev/disk/by-partlabel/CRYPTKEY";
    };
  in {
    "crypt-nixos" = crypt-template // {
      device = "/dev/disk/by-label/CRYPT_NIXOS";
      fallbackToPassword = true;
    };
  };

  fileSystems."/" =
    { device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" "noatime" "ssd" "autodefrag" "discard=async" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" "ssd" "autodefrag" "discard=async" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=persist" "compress=zstd" "noatime" "ssd" "autodefrag" "discard=async" ];
      neededForBoot = true;
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=log" "compress=zstd" "noatime" "ssd" "autodefrag" "discard=async" ];
      neededForBoot = true;
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };

  fileSystems."/swap" =
    { device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=swap" "noatime" ];
      neededForBoot = true;
    };

  swapDevices = [ { device = "/swap/swapfile"; } ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

