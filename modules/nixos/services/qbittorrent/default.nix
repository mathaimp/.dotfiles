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
  cfg = config.${namespace}.services.qbittorrent;
in
{
  options.${namespace}.services.qbittorrent = with types; {
    enable = mkBoolOpt false "Enable qbittorrent";
  };

  config = mkIf cfg.enable {
    services.qbittorrent = {
      enable = true;
      openFirewall = true;
      user = config.services.jellyfin.user;
      group = config.services.jellyfin.group;
      profileDir = "/data";
      webuiPort = 8081;
    };
  };
}
