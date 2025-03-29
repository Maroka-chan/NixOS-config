{ config, pkgs, inputs, ... }:
{
  imports =
  [
    ./hardware-configuration.nix
    ./deployment-user.nix
    ./networkshare-user.nix
    ./reverse-proxy.nix
    ./services
    inputs.vpn-confinement.nixosModules.default
    inputs.yuttari.nixosModule
    #../../modules/disko/btrfs_luks_impermanence.nix
    #(import ../../modules/disko/btrfs_luks_raid1.nix [ "/dev/sda" "/dev/sdb" "/dev/sdc" ])
  ];

  nix.settings.trusted-users = [ "deploy" ];
  #documentation.nixos.includeAllModules = true;
  #documentation.nixos.extraModules = [inputs.vpn-confinement.nixosModules.default];

  impermanence.enable = true;
  filesystem.btrfs.enable = true;

  services.yuttari.enable = true;
  services.yuttari.openFirewall = true;

  #boot.initrd.luks.devices."crypt-data-1".device = lib.mkForce "/dev/disk/by-label/CRYPT_DATA_1";
  #boot.initrd.luks.devices."crypt-data-2".device = lib.mkForce "/dev/disk/by-label/CRYPT_DATA_2";
  #boot.initrd.luks.devices."crypt-data-3".device = lib.mkForce "/dev/disk/by-label/CRYPT_DATA_3";

  #fileSystems."/data".device = lib.mkForce "/dev/disk/by-label/DATA";

  #fileSystems."/".device = lib.mkForce "/dev/disk/by-label/NIXOS";
  #fileSystems."/nix".device = lib.mkForce "/dev/disk/by-label/NIXOS";
  #fileSystems."/persist".device = lib.mkForce "/dev/disk/by-label/NIXOS";
  #fileSystems."/swap".device = lib.mkForce "/dev/disk/by-label/NIXOS";
  #fileSystems."/var/log".device = lib.mkForce "/dev/disk/by-label/NIXOS";
  #fileSystems."/boot".device = lib.mkForce "/dev/disk/by-label/BOOT";
  #fileSystems."/data".device = lib.mkForce "/dev/disk/by-label/DATA";

  #swapDevices = lib.mkForce [ { device = "/swap/swapfile"; } ];

  #fileSystems."/data".device = lib.mkForce "/dev/disk/by-label/DATA";

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;

  vpnNamespaces.wg = {
    enable = true;
    accessibleFrom = [
      "192.168.1.0/24"
      "fd25:9ab6:6133::/64"
    ];
    wireguardConfigFile = config.age.secrets.vpn-wireguard.path;
    portMappings = [
      { from = 9091; to = 9091; }
      { from = 3000; to = 3000; }
      { from = 11470; to = 11470; }
      { from = 12470; to = 12470; }
    ];
    openVPNPorts = [
      { port = 12340; protocol = "both"; }
    ];
  };

  services.stremio-server.enable = true;
  systemd.services.stremio-server.vpnConfinement = {
    enable = true;
    vpnNamespace = "wg";
  };

  # State to persist.
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/acme/yuttari.moe"
      "/var/lib/acme/.lego/yuttari.moe"
      "/var/lib/acme/.lego/accounts"
    ];
    files = [ # TODO: Are these needed here? Just read directly from /persist?
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
  #security.apparmor.enable = true;
  #security.apparmor.killUnconfinedConfinables = true;

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

  # TODO: add stateversion globally for all configs?
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
