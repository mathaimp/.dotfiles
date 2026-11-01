{
  flake.nixosModules.caddy =
    {
      config,
      pkgs,
      ...
    }:
    {
      sops.secrets."duckdns-token" = { };

      services.caddy = {
        enable = true;
        package = pkgs.caddy.withPlugins {
          plugins = [ "github.com/caddy-dns/duckdns@v0.5.0" ];
          hash = "sha256-IJkUtJc9Gz9WnHyBmHXTjXI6K1wyHQoVRRP8l3A3na0=";
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
