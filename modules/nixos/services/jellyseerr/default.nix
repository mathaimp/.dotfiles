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
    services.caddy.virtualHosts."jellyseerr.mathai.duckdns.org".extraConfig = ''
      encode zstd gzip
      reverse_proxy localhost:5055
      request_body {
        max_size 500MB
      }
    '';

    virtualisation.oci-containers.containers = {
      jellyseerr = {
        pull = "newer";
        image = "ghcr.io/fallenbagel/jellyseerr:latest";
        autoStart = true;
        environment = {
          LOG_LEVEL = "debug";
          TZ = "Asia/Kolkata";
          PORT = "5055";
        };
        ports = [ "127.0.0.1:5055:5055" ];
        volumes = [
          "/data/jellyseerr/config:/app/config"
        ];
      };
    };
  };
}
