{ pkgs, ...}:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableAllFirmware = true;

  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.config.allowUnfree = true;

  # Networking
  networking = {
    nameservers = [ "1.1.1.2" "1.0.0.2" ];
    dhcpcd.extraConfig = "nohook resolv.conf";
  };

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
  ];

  # Shell
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ]; # Needed for zsh completion for system packages
  users.defaultUserShell = pkgs.zsh;

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
