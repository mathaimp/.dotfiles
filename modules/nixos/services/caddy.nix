{
  flake.nixosModules.caddy =
    { config
    , pkgs
    , ...
    }:
    {
      sops.secrets."duckdns-token" = { };

      services.caddy = {
        enable = true;
        package = pkgs.caddy.withPlugins {
          plugins = [ "github.com/caddy-dns/duckdns@v0.5.0" ];
          hash = "sha256-PC0r+dzU9Dp1yjE+k6AXGct6Hhz0zbE0EWbnweHwl2o=";
        };
        globalConfig = ''
          acme_dns duckdns {
            api_token {env.DUCKDNS_TOKEN}
          }
        '';
      };

      systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.secrets."duckdns-token".path;

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
    };
}
