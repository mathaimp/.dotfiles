{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.calibre-web;
in
{
  options.${namespace}.services.calibre-web = with types; {
    enable = mkBoolOpt false "Enable calibre-web";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "hardcover-api" = { };
    };

    services.nginx.virtualHosts."calibre.mathai.duckdns.org" = {
      useACMEHost = "mathai.duckdns.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8083";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          client_max_body_size 500M;
          proxy_read_timeout   600s;
          proxy_send_timeout   600s;
          send_timeout         600s;
        '';
      };
    };

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
        ports = [ "0.0.0.0:8084:8084" ];
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
