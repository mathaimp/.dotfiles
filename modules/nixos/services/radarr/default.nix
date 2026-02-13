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
  cfg = config.${namespace}.services.radarr;
in
{
  options.${namespace}.services.radarr= with types; {
    enable = mkBoolOpt false "Enable radarr";
  };

  config = mkIf cfg.enable {
    services.radarr = {
      enable = true;
      openFirewall = true;
      group = config.services.jellyfin.group;
      user = config.services.jellyfin.user;
      dataDir = "/data/radarr";
    };
  };
}
