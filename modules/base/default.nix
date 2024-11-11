{ pkgs, ...}:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableAllFirmware = true;

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

  # Files to persist
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/lib/nixos"
      "/var/lib/fwupd"
    ];
    files = [
      "/etc/machine-id"
      "/var/lib/systemd/random-seed"
    ];
  };

  # Workaround for the following service failing with a bind mount for /etc/machine-id
  # see: https://github.com/nix-community/impermanence/issues/229
  boot.initrd.systemd.suppressedUnits = [ "systemd-machine-id-commit.service" ];
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

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
