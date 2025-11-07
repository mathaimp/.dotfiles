{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.kdeconnect;
in
{
  options.${namespace}.services.kdeconnect = with types; {
    enable = mkBoolOpt false "Enable kdeconnect";
  };

  config = mkIf cfg.enable {
    services.kdeconnect = {
      enable = true;
      indicator = false;
    };
  };
}
