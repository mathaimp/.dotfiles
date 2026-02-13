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
  cfg = config.${namespace}.services.bazarr;
in
{
  options.${namespace}.services.bazarr = with types; {
    enable = mkBoolOpt false "Enable bazarr";
  };

  config = mkIf cfg.enable {
    services.bazarr = {
      enable = true;
      openFirewall = true;
      group = config.services.jellyfin.group;
      user = config.services.jellyfin.user;
      dataDir = "/data/bazarr";
    };
  };
}
