{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.radarr;
in
{
  options.${namespace}.services.radarr = with types; {
    enable = mkBoolOpt false "Enable radarr";
  };

  config = mkIf cfg.enable {
    services.radarr = {
      enable = true;
      inherit (config.services.jellyfin) user group;
      dataDir = "/data/radarr";
    };
  };
}
