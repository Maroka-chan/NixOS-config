{ config, pkgs, lib, inputs, ... }:
{
  imports =
  [
    ./hardware-configuration.nix
    ./deployment-user.nix
    ./networkshare-user.nix
    ./services
    inputs.vpn-confinement.nixosModules.default
  ];

  nix.settings.trusted-users = [ "deploy" ];

  impermanence.enable = true;
  filesystem.btrfs.enable = true;

  ### Reverse Proxy ###
  age.secrets.lego-env.file = ../../secrets/lego-env.age;

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "acme.lxd3v@simplelogin.com";

  security.acme.certs."yuttari.moe" = {
    domain = "*.yuttari.moe";
    dnsProvider = "cloudflare";
    dnsResolver = "1.1.1.1:53";
    #server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    credentialFiles."CF_DNS_API_TOKEN_FILE" = config.age.secrets.lego-env.path;
  };

  systemd.services.adguardhome.serviceConfig.Group = "acme";
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    port = 3001;
    settings = {
      #tls = {
      #  enabled = true;
      #  certificate_chain = "/var/lib/acme/yuttari.moe/cert.pem";
      #  private_key = "/var/lib/acme/yuttari.moe/key.pem";
      #  port_https = 444;
      #};
      http.address = "0.0.0.0:3001";
      dns = {
        upstream_dns = [ "https://dns.quad9.net/dns-query" ];
        bootstrap_dns = [ "1.1.1.2" ];
        enable_dnssec = true;
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;

        parental_enabled = false;  # Parental control-based DNS requests filtering.
        safe_search = {
          enabled = false;  # Enforcing "Safe search" option for search engines, when possible.
        };
      };
      filters = map(url: { enabled = true; url = url; }) [
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"   # The Big List of Hacked Malware Web Sites
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # malicious url blocklist
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_48.txt"  # HaGeZi's Pro Blocklist
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_50.txt"  # uBlock₀ filters – Badware risks
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_45.txt"  # HaGeZi's Allowlist Referral
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_47.txt"  # HaGeZi's Gambling Blocklist
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_12.txt"  # Dandelion Sprout's Anti-Malware List
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_55.txt"  # HaGeZi's Badware Hoster blocklist
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_54.txt"  # HaGeZi's DynDNS Blocklist
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_56.txt"  # HaGeZi's The World's Most Abused TLDs
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_44.txt"  # HaGeZi's Threat Intelligence Feeds
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 3001 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.nginx = {
      enable = true;
      group = "acme";

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      # Only allow PFS-enabled ciphers with AES256
      sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

      appendHttpConfig = ''
        # Minimize information leaked to other domains
        add_header 'Referrer-Policy' 'origin-when-cross-origin';

        # Disable embedding as a frame
        add_header X-Frame-Options DENY;

        # Prevent injection of code in other mime types (XSS Attacks)
        add_header X-Content-Type-Options nosniff;

        # This might create errors
        proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";
      '';

      # other Nginx options
      virtualHosts."media.yuttari.moe" =  {
        useACMEHost = "yuttari.moe";
        forceSSL = true;
        locations."/".proxyPass = "http://192.168.15.1:11470/";
      };
  };
  #####################

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

  systemd.services.dnstest = {
    vpnConfinement = {
      enable = true;
      vpnNamespace = "wg";
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
    vpnConfinement = {
      enable = true;
      vpnNamespace = "wg";
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
