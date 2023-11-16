{ config, pkgs, ... }:
{
  imports =
  [
    ./bootloader.nix
    ./firewall.nix
    ./deployment-user.nix
    ./services
  ];

  networking.hostName = "akebi";
  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Set users to be immutable
  users.mutableUsers = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Secrets
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;

  # BTRFS Settings
  services.btrfs.autoScrub.enable = true;
  # Impermanence
  btrfs-impermanence.enable = true;

  # State to persist.
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/private/uptime-kuma"
      "/var/lib/jellyfin"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
  ];

  # Enable AppArmor
  security.apparmor.enable = true;
  security.apparmor.killUnconfinedConfinables = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

  # Automatic Updates
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    channel = "https://nixos.org/channels/nixos-23.05-small";
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
