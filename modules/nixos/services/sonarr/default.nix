{
  config,
  lib,
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
      inherit (config.services.jellyfin) user group;
      dataDir = "/data/sonarr";
    };
  };
}
