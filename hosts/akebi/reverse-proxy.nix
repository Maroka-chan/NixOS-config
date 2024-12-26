{ config, ... }:
{
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
}
