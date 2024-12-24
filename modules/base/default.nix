{ config, pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableAllFirmware = true;

  # Fixes logitech scrollwheel when wireless
  boot.blacklistedKernelModules = [ "hid_logitech_dj" "hid_logitech_hidpp" ];

  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.config.allowUnfree = true;

  # Networking
  networking = {
    #nameservers = [ "1.1.1.2" "1.0.0.2" ];
    dhcpcd.extraConfig = "nohook resolv.conf";
  };

  ## Remove fallbackDNS
  services.resolved.extraConfig =
  ''
    FallbackDNS=
  '';

  # Firewall
  networking.firewall = {
    enable = true;
    allowPing = false;
  };

  # Firmware Updater
  services.fwupd.enable = true;

  # inotify
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = "1048576";
    "fs.inotify.max_user_instances" = "256";
  };

  # Base packages
  environment.systemPackages = with pkgs; [
    zip unzip
    (btop.override {rocmSupport = true;})
    comma
  ];

  # Remove sudo lectures
  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

  # Thermal Management
  services.thermald.enable = true;

  # Increase amount of files we can have open
  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "16384";
  }];

  # Configure Disko VM
  virtualisation.vmVariantWithDisko = {
    virtualisation = {
      cores = 4;
      memorySize = 8096;
      qemu.options = [ "-enable-kvm" "-vga virtio" "-display gtk,gl=on" ];
      writableStoreUseTmpfs = false;

      fileSystems."/var/log".neededForBoot = true;
      fileSystems."/swap".neededForBoot = true;

      # Mount local .ssh directory, so the secrets can be decrypted.
      sharedDirectories."secrets_decryption_key" = {
        source = "/home/$USER/.ssh";
        target = dirOf (builtins.head config.age.identityPaths);
      };
    };

    # Add dummy cryptkey for VM
    disko.devices.disk.cryptkey = {
      type = "disk";
      content.type = "gpt";

      content.partitions.cryptkey = {
        size = "4096";
        label = "CRYPTKEY";

        content = {
          type = "filesystem";
          format = "vfat";
        };
      };
    };
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Nix Settings
  nix.settings = {
    auto-optimise-store = true;
    builders-use-substitutes = true;
    substituters = [
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    experimental-features = "nix-command flakes";
  };
}
