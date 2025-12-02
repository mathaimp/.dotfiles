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
      package = pkgs.nextcloud32;
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

    services.nginx.virtualHosts."nixcloud".listen = [
      {
        addr = "127.0.0.1";
        port = 8009;
      }
    ];

    services.nginx.virtualHosts."cloud.mathai.duckdns.org" = {
      forceSSL = true;
      useACMEHost = "mathai.duckdns.org";
      serverName = "cloud.mathai.duckdns.org";
      root = "/data/nextcloud"; # Nextcloud installation path (adjust if needed)
      locations."/" = {
        proxyPass = "http://127.0.0.1:8009";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}
