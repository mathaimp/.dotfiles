{
  flake.nixosModules.bazarr =
    { config
    , ...
    }:
    {
      services.bazarr = {
        enable = true;
        inherit (config.services.jellyfin) user group;
        dataDir = "/data/bazarr";
      };
      services.caddy.virtualHosts."bazarr.mathai.duckdns.org".extraConfig = ''
        encode zstd gzip
        reverse_proxy localhost:6767
      '';
    };
}
