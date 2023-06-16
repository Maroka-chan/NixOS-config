{ config, pkgs, ... }:
let
  secrets_path = "/persist/etc/nixos/secrets";
in
{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "btrfs" ];
  hardware.enableAllFirmware = true;

  # Networking and System Settings
  networking.hostName = "aisaka";
  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_US.UTF-8";
  users.mutableUsers = false;
  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.2" "1.0.0.2" ];

  # Secrets
  sops.defaultSopsFile = secrets_path + "/secrets.yaml";
  sops.validateSopsFiles = false;
  sops.age.sshKeyPaths = [];
  sops.age.keyFile = secrets_path + "/keys.txt";
  sops.gnupg.sshKeyPaths = [];

  sops.secrets.maroka-password = {
      neededForUsers = true;
  };

  # Firewall
  networking.firewall = {
    enable = true;
    allowPing = false;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    neovim
  ];

  # Users
  users.users.maroka = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    passwordFile = config.sops.secrets.maroka-password.path;
    packages = with pkgs; [];
  };

  # Remove sudo lectures
  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

  # Impermanence
  btrfs-impermanence.enable = true;

  # Files to persist
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  # Automatic Updates
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    channel = "https://nixos.org/channels/nixos-unstable";
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
  system.stateVersion = "23.05"; # Did you read the comment?
}
