{
  flake.nixosModules.qbittorent =
    {
      config,
      ...
    }:
    {
      services.qbittorrent = {
        enable = true;
        inherit (config.services.jellyfin) user group;
        profileDir = "/data";
        webuiPort = 8081;
      };

      services.caddy.virtualHosts."torrent.mathai.duckdns.org".extraConfig = ''
        encode zstd gzip
        reverse_proxy localhost:8081
      '';
    };
}
