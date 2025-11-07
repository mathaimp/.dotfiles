{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.system.automatic-timezone;
in
{
  options.${namespace}.system.automatic-timezone = with types; {
    enable = mkBoolOpt false "Enable automatic-timezone.";
  };

  config = mkIf cfg.enable {
    services.automatic-timezoned.enable = true;
  };
}
