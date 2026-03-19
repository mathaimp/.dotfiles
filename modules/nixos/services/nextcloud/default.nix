{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.nextcloud;
in
{
  options.${namespace}.services.nextcloud = with types; {
    enable = mkBoolOpt false "Enable nextcloud";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "nextcloud" = { };
    };

    services.nextcloud = {
      enable = true;
      configureRedis = true;
      package = pkgs.nextcloud33;
      hostName = "nixcloud";
      home = "/data/nextcloud";
      https = true;
      settings = {
        trusted_proxies = [
          "localhost"
          "127.0.0.1"
          "cloud.mathai.duckdns.org"
        ];
        trusted_domains = [ "cloud.mathai.duckdns.org" ];
        overwriteprotocol = "https";
      };
      config = {
        dbtype = "sqlite";
        dbuser = "nextcloud";
        dbname = "nextcloud";
        adminuser = "root";
        adminpassFile = config.sops.secrets."nextcloud".path;
      };
    };
    services.caddy.virtualHosts."cloud.mathai.duckdns.org".extraConfig = ''
      encode zstd gzip
      reverse_proxy localhost:8009
      request_body {
        max_size 10GB
      }
      header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "SAMEORIGIN"
        X-Permitted-Cross-Domain-Policies "none"
        X-Robots-Tag "noindex, nofollow"
        X-XSS-Protection "1; mode=block"
        -X-Powered-By
      }
    '';
  };
}
