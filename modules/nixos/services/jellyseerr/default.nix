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
