 { pkgs, ... }:
 {
    project.name = "jellyfin";
    services.jellyfin = {
        service = {
            restart = "unless-stopped";
            image = "ghcr.io/linuxserver/jellyfin:latest";
            volumes = [
                "config:/config"
                # "/docker_data/media_data/media:/data:ro"
                ];
            environment = {
                PUID    = "1000";
                PGID    = "1000";
                TZ      = "Europe/London";
            };
            ports = [
                "8096:8096"
                "8920:8920"
                ];
            labels = {
                "traefik.enable"                                    = "true";
                "traefik.http.routers.jellyfin.entrypoints"         = "web,websecure";
                "traefik.http.routers.jellyfin.rule"                = "Host(`media.yuttari.moe`)";
                "traefik.http.routers.jellyfin.tls"                 = "true";
                "traefik.http.routers.jellyfin.tls.certresolver"    = "production";
            };
        };
    };

    docker-compose.raw = {
      volumes = {
        config = {};
      };
    };
 }