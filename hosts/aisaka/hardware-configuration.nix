{ config, lib, pkgs, modulesPath, ... }:
{
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "uas" "usbcore" "usb_storage" "vfat" "nls_cp437" "nls_iso8859_1" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices = 
  let
    USB_ID = "3F09-DDCE";
  in
  {
    "crypt-nixos" = {
      device = "/dev/disk/by-label/CRYPT_NIXOS";
      keyFile = "/key/aisaka-crypt.key";
      fallbackToPassword = true;
      allowDiscards = true;
      preOpenCommands = ''
        mkdir -m 0755 -p /key
	sleep 2
	mount -n -t vfat -o ro `findfs UUID=${USB_ID}` /key
      '';
      postOpenCommands = ''
        umount /key
	rm -rf /key
      '';
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
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
