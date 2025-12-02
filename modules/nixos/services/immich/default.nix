{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.immich;
in
{
  options.${namespace}.services.immich = with types; {
    enable = mkBoolOpt false "Enable immich";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "immich" = { };
    };

    services.immich = {
      enable = true;

      settings = builtins.fromJSON (builtins.readFile ./immich.json);

      secretsFile = config.sops.secrets."immich".path;

      host = "0.0.0.0";
      mediaLocation = "/data/immich";

      accelerationDevices = null;

      machine-learning = {
        enable = true;
        # As immich user has no home
        environment = {
          HF_XET_CACHE = "/var/cache/immich/huggingface-xet";
        };
      };
      redis = {
        enable = true;
      };

      database = {
        enable = true;
      };
    };

    users.users.immich.extraGroups = [
      "video"
      "render"
    ];

    services.nginx.virtualHosts."immich.mathai.duckdns.org" = {
      useACMEHost = "mathai.duckdns.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:2283";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_read_timeout   600s;
          proxy_send_timeout   600s;
          send_timeout         600s;
        '';
      };
    };
  };
}
