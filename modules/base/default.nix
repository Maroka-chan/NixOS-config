{ inputs, config, lib, pkgs, ...}:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableAllFirmware = true;

  # inotify
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = "1048576";
    "fs.inotify.max_user_instances" = "256";
  };

  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.config.allowUnfree = true;

  networking = {
    nameservers = [ "1.1.1.2" "1.0.0.2" ];
    dhcpcd.extraConfig = "nohook resolv.conf";
    networkmanager.dns = "none";
  };

  # The above doesn't seem to actually update resolv.conf, so until that is fixed:
  environment.etc = {
    "resolv.conf".text = ''
      nameserver 192.168.0.1
      nameserver 1.1.1.2
      nameserver 1.0.0.2
      options edns0
    '';
  };

  # Firewall
  networking.firewall = {
    enable = true;
    allowPing = false;
  };

  # Firmware Updater
  services.fwupd.enable = true;

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
}
