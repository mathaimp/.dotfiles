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
  cfg = config.${namespace}.services.cloudflare-warp;
in
{
  options.${namespace}.services.cloudflare-warp = with types; {
    enable = mkBoolOpt false "Enable cloudflare-warp";
  };

  config = mkIf cfg.enable {
    services.cloudflare-warp = {
      enable = true;
      openFirewall = true;
    };
  };
}
