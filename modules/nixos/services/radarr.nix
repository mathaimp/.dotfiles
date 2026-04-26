{
  flake.nixosModules.radarr =
    { config
    , ...
    }:
    {
      services.radarr = {
        enable = true;
        inherit (config.services.jellyfin) user group;
        dataDir = "/data/radarr";
      };
      services.caddy.virtualHosts."radarr.mathai.duckdns.org".extraConfig = ''
        encode zstd gzip
        reverse_proxy localhost:7878
      '';
    };
}
