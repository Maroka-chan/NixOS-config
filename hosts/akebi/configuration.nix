{ config, pkgs, lib, inputs, ... }:
{
  imports =
  [
    ./hardware-configuration.nix
    ./deployment-user.nix
    ./networkshare-user.nix
    ./services
    inputs.vpnconfinement.nixosModules.default
  ];

  nix.settings.trusted-users = [ "deploy" ];

  systemd.services.dnstest = {
    vpnconfinement = {
      enable = true;
      vpnnamespace = "wg";
    };

    script = let
      vpn-test = pkgs.writeShellApplication {
        name = "vpn-test";

        runtimeInputs = with pkgs; [util-linux unixtools.ping coreutils curl bash libressl netcat-gnu openresolv dig];

        text = ''
          cd "$(mktemp -d)"

          # Print resolv.conf
          echo "/etc/resolv.conf contains:"
          cat /etc/resolv.conf

          # Query resolvconf
          echo "resolvconf output:"
          resolvconf -l
          echo ""

          # Get ip
          echo "Getting IP:"
          curl -s ipinfo.io

          echo -ne "DNS leak test:"
          curl -s https://raw.githubusercontent.com/macvk/dnsleaktest/b03ab54d574adbe322ca48cbcb0523be720ad38d/dnsleaktest.sh -o dnsleaktest.sh
          chmod +x dnsleaktest.sh
          ./dnsleaktest.sh

          echo "resolv:"
          ls /etc/resolv.conf
        '';
      };
    in "${vpn-test}/bin/vpn-test";
  };

  systemd.services.vpn-test-service = {
    vpnconfinement = {
      enable = true;
      vpnnamespace = "wg";
    };

    script = let
      dnspeep = pkgs.callPackage pkgs.rustPlatform.buildRustPackage rec {
        pname = "dnspeep";
        version = "0.1.3";

        src = pkgs.fetchFromGitHub {
          owner = "jvns";
          repo = "dnspeep";
          rev = "v${version}";
          sha256 = "sha256-QpUbHiMDQFRCTVyjrO9lfQQ62Z3qanv0j+8eEXjE3n4=";
        };

        cargoLock = {
          lockFile = "${src}/Cargo.lock";
          allowBuiltinFetchGit = true;
        };

        buildInputs = with pkgs; [
          libpcap
        ];
        LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
      };
      vpn-test = pkgs.writeShellApplication {
        name = "vpn-test";

        runtimeInputs = with pkgs; [coreutils curl openresolv dnspeep];

        text = ''
          dnspeep

         # cd "$(mktemp -d)"

         # # Print resolv.conf
         # echo "/etc/resolv.conf contains:"
         # cat /etc/resolv.conf

         # # Query resolvconf
         # echo "resolvconf output:"
         # resolvconf -l
         # echo ""

         # # Get ip
         # echo "Getting IP:"
         # curl -s ipinfo.io

         # #cat /etc/test.file

         # echo -ne "DNS leak test:"
         # curl -s https://raw.githubusercontent.com/macvk/dnsleaktest/b03ab54d574adbe322ca48cbcb0523be720ad38d/dnsleaktest.sh -o dnsleaktest.sh
         # chmod +x dnsleaktest.sh
         # ./dnsleaktest.sh

         # ls /var/run/nscd
         # cat /etc/resolv.conf

         # #echo "starting netcat on port ${builtins.toString 2022}:"
         # #nc -vnlp ${builtins.toString 2022}
        '';
      };
    in "${vpn-test}/bin/vpn-test";

    #bindsTo = ["netns@wg.service"];
    requires = ["network-online.target"];
    #after = ["wg.service"];
   # serviceConfig = {
   #   User = "deploy";
   #   NetworkNamespacePath = "/var/run/netns/wg";
   #   BindReadOnlyPaths = ["/etc/netns/wg/resolv.conf:/etc/resolv.conf:norbind" "/data/test.file:/etc/test.file:norbind"];
   # };
  };

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;

  # Set users to be immutable
  users.mutableUsers = false;

  # Secrets
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/var/lib/sops-nix/keys.txt";
  sops.age.generateKey = true;

  # Filesystem
  filesystem.btrfs = {
    enable = true;
    impermanence.enable = true;
  };

  # State to persist.
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/private/uptime-kuma"
      "/var/lib/jellyfin"
      "/var/lib/tailscale"
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

  # Automatic Updates
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    channel = "https://nixos.org/channels/nixos-24.05-small";
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
