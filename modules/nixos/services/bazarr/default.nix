{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.bazarr;
in
{
  options.${namespace}.services.bazarr = with types; {
    enable = mkBoolOpt false "Enable bazarr";
  };

  config = mkIf cfg.enable {
    services.bazarr = {
      enable = true;
      inherit (config.services.jellyfin) user group;
      dataDir = "/data/bazarr";
    };
  };
}
