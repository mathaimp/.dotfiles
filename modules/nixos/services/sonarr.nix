{
  flake.nixosModules.sonarr =
    { config
    , ...
    }:
    {
      services.sonarr = {
        enable = true;
        inherit (config.services.jellyfin) user group;
        dataDir = "/data/sonarr";
      };
      services.caddy.virtualHosts."sonarr.mathai.duckdns.org".extraConfig = ''
        encode zstd gzip
        reverse_proxy localhost:8989
      '';
    };
}
