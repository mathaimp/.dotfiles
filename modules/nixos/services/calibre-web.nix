{
  flake.nixosModules.calibre-web =
    { config
    , ...
    }:
    {
      sops.secrets = {
        "hardcover-api" = { };
      };
      services.caddy.virtualHosts."calibre.mathai.duckdns.org".extraConfig = ''
        encode zstd gzip
        reverse_proxy localhost:8083
      '';

      virtualisation.oci-containers.containers = {
        calibre-web-automated = {
          pull = "newer";
          image = "docker.io/crocodilestick/calibre-web-automated:latest";
          autoStart = true;
          environment = {
            PUID = "1000";
            PGID = "1000";
            TZ = "Asia/Kolkata";
            NETWORK_SHARE_MODE = "false";
          };
          environmentFiles = [ config.sops.secrets."hardcover-api".path ];
          volumes = [
            "/data/calibre/config:/config"
            "/data/calibre/ingest:/cwa-book-ingest"
            "/data/calibre/library:/calibre-library"
            "/data/calibre/plugins:/config/.config/calibre/plugins"
          ];
          ports = [ "0.0.0.0:8083:8083" ];
        };

        calibre-web-automated-book-downloader = {
          pull = "newer";
          image = "ghcr.io/calibrain/calibre-web-automated-book-downloader:latest";
          autoStart = true;
          ports = [ "127.0.0.1:8084:8084" ];
          environment = {
            FLASK_PORT = "8084";
            LOG_LEVEL = "info";
            BOOK_LANGUAGE = "en";
            USE_BOOK_TITLE = "true";
            TZ = "Asia/Kolkata";
            APP_ENV = "prod";
            UID = "1000";
            GID = "100";
            CWA_DB_PATH = "/auth/app.db";
          };
          volumes = [
            "/data/calibre/ingest:/cwa-book-ingest"
            "/data/calibre/config/app.db:/auth/app.db:ro"
          ];
        };
      };
    };
}
