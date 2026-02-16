{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.jellyseerr;
  dataDir = "/data/jellyseerr";
in
{
  options.${namespace}.services.jellyseerr = with types; {
    enable = mkBoolOpt false "Enable jellyseerr";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 5055 ];

    services.nginx.virtualHosts."jellyseerr.mathai.duckdns.org" = {
      useACMEHost = "mathai.duckdns.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5055";
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
      jellyseerr = {
        pull = "newer";
        image = "ghcr.io/fallenbagel/jellyseerr:latest";
        autoStart = true;
        environment = {
          LOG_LEVEL = "debug";
          TZ        = "Asia/Kolkata";
          PORT      = "5055";
        };
        networks = [ "host" ];
        volumes = [
          "/data/jellyseerr/config:/app/config"
        ];
      };
    };
  };
}
