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
  cfg = config.${namespace}.services.caddy;
in
{
  options.${namespace}.services.caddy = with types; {
    enable = mkBoolOpt false "Enable caddy";
  };

  config = mkIf cfg.enable {
    sops.secrets."duckdns-token" = { };

    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/duckdns@v0.5.0" ];
        hash = "sha256-uMYFZJ+dOoahO9+nAU+bGiuFQRmPbPWFwH1uH8xBcFQ";
      };
      globalConfig = ''
        acme_dns duckdns {
          api_token {env.DUCKDNS_TOKEN}
        }
      '';
      # extraConfig = ''
      #   (auth) {
      #     forward_auth localhost:9091 {
      #       uri /api/authz/forward-auth
      #       copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
      #     }
      #   }
      # '';
    };

    systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.secrets."duckdns-token".path;

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
