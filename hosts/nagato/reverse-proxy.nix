{pkgs, ...}: {
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [443];

  services.caddy = {
    enable = true;

    package = pkgs.caddy.withPlugins {
      plugins = ["github.com/caddy-dns/porkbun@v0.3.1"];
      hash = "sha256-GKtPd73R/7ggu3fBFilkhyKi45lkAAQFsftwg5pmWW4=";
    };

    virtualHosts."immich.home.alexbmj.com" = {
      extraConfig = ''
        reverse_proxy http://localhost:2283

        tls {
          dns porkbun {
            api_key {env.PORKBUN_API_KEY}
            api_secret_key {env.PORKBUN_API_SECRET_KEY}
          }
          resolvers 1.1.1.1
        }

        header {
          Referrer-Policy "origin-when-cross-origin"
          X-Frame-Options "DENY"
          X-Content-Type-Options "nosniff"
        }
      '';
    };

    virtualHosts."uptime.home.alexbmj.com" = {
      extraConfig = ''
        reverse_proxy http://localhost:3001

        tls {
          dns porkbun {
            api_key {env.PORKBUN_API_KEY}
            api_secret_key {env.PORKBUN_API_SECRET_KEY}
          }
          resolvers 1.1.1.1
        }

        header {
          Referrer-Policy "origin-when-cross-origin"
          X-Frame-Options "DENY"
          X-Content-Type-Options "nosniff"
        }
      '';
    };
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile = [
    "/etc/caddy/secrets/caddy-env"
  ];
}
