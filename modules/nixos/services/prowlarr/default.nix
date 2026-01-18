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
  cfg = config.${namespace}.services.prowlarr;
in
{
  options.${namespace}.services.prowlarr = with types; {
    enable = mkBoolOpt false "Enable prowlarr";
  };

  config = mkIf cfg.enable {
    services.prowlarr = {
      enable = true;
      openFirewall = true;
      dataDir = "/data/prowlarr";
    };
    services.flaresolverr = {
      enable = true;
      openFirewall = true;
    };
  };
}
