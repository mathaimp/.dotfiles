{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.qbittorrent;
in
{
  options.${namespace}.services.qbittorrent = with types; {
    enable = mkBoolOpt false "Enable qbittorrent";
  };

  config = mkIf cfg.enable {
    services.qbittorrent = {
      enable = true;
      inherit (config.services.jellyfin) user group;
      profileDir = "/data";
      webuiPort = 8081;
    };
  };
}
