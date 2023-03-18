{ config, pkgs, ... }:
{
  imports =
  [
    "${builtins.fetchTarball "https://github.com/hercules-ci/arion/tarball/master"}/nixos-module.nix"
    "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/modules/age.nix"
    ./deployments/jellyfin
    ./hardware-configuration.nix  # Include the results of the hardware scan.
  ];

  # Bootloader.
  if isPath "/sys/firmware/efi/efivars" then {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
  } else {
    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    boot.loader.grub.device = "/dev/disk/by-label/NIXBOOT";
  }

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "btrfs" ];
  hardware.enableAllFirmware = true;


  networking.hostName = "nixos"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  networking.defaultGateway = "192.168.0.1";

  networking = {
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    arion
    neovim
    (pkgs.callPackage "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/pkgs/agenix.nix" {})
  ];
  

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
  # virtualisation.docker.enableNvidia = true;

  virtualisation.docker.rootless = {
      enable = true;
      setSocketVariable = true;
  };



  # State to persist.
  # On reboot the system restores the blank btrfs root snapshot
  environment.etc = {
    nixos.source = "/persist/etc/nixos";
    # adjtime.source = "/persist/etc/adjtime";
    NIXOS.source = "/persist/etc/NIXOS";
    machine-id.source = "/persist/etc/machine-id";
    # ssh.source = "/persist/etc/ssh";
  };
  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

  # Note `lib.mkBefore` is used instead of `lib.mkAfter` here.
  boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
    mkdir -p /mnt

    mount -t btrfs /dev/mapper/enc /mnt

    btrfs subvolume list -o /mnt/root |
    cut -f9 -d' ' |
    while read subvolume; do
      echo "deleting /$subvolume subvolume..."
      btrfs subvolume delete "/mnt/$subvolume"
    done &&
    echo "deleting /root subvolume..." &&
    btrfs subvolume delete /mnt/root

    echo "restoring blank /root subvolume..."
    btrfs subvolume snapshot /mnt/root-blank /mnt/root

    umount /mnt
  '';

  users.mutableUsers = false;

  age.secrets.maroka_pass.file = "./.secrets/maroka_pass.age";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.maroka = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    passwordFile = config.age.secrets.maroka_pass.path;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMLXkO6gEHyTSm+CJuhWPQRMJTM7psG2JzBROSTbK8op maroka@Arch-Desktop" ];
    packages = with pkgs; [];
  };


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Firewall
  networking.firewall = {
    enable = true;
    allowPing = false;
    allowedTCPPorts = [
      22
      8096 8920 # Jellyfin
      ];
  };

  # Automatic Updates
  system.autoUpgrade = {
  	enable = true;
    allowReboot = true;
    channel = "https://nixos.org/channels/nixos-22.11-small";
  };

  # Optimise nix store
  nix.settings.auto-optimise-store = true;
  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
