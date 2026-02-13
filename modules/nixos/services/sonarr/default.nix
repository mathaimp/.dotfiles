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
  cfg = config.${namespace}.services.sonarr;
in
{
  options.${namespace}.services.sonarr = with types; {
    enable = mkBoolOpt false "Enable sonarr";
  };

  config = mkIf cfg.enable {
    services.sonarr = {
      enable = true;
      openFirewall = true;
      group = config.services.jellyfin.group;
      user = config.services.jellyfin.user;
      dataDir = "/data/sonarr";
    };
  };
}
