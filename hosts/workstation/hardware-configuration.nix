{
  config,
  lib,
  pkgs,
  ...
}: let
  kernelPackages = pkgs.linuxPackages;
in {
  # PCSpecialist Destroyer ICUE Goliath
  # ASUS ROG STRIX X670E-A GAMING WIFI / AMD Ryzen 9 7950X3D / 128GB RAM
  # NVIDIA GeForce RTX 4090 (AD102) + AMD Raphael iGPU
  # Corsair MP600 CORE XT 2TB NVMe
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [
    "kvm-amd"
    "ryzen-smu"
    "i2c-dev"
    "ddcci_backlight"
  ];
  boot.extraModulePackages = [kernelPackages.ryzen-smu kernelPackages.ddcci-driver];
  boot.kernelPackages = kernelPackages;

  boot.plymouth = {
    enable = true;
    themePackages = [pkgs.mikuboot];
    theme = "mikuboot";
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp9s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.i2c.enable = true;
}
