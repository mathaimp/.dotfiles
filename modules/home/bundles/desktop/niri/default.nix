{
  config,
  lib,
  libEx,
  namespace,
  ...
}:
with lib;
with libEx.${namespace};
let
  cfg = config.${namespace}.bundles.desktop.niri;
in
{
  options.${namespace}.bundles.desktop.niri = with types; {
    enable = mkBoolOpt false "Whether or not to enable niri bundle configuration.";
  };

  config = mkIf cfg.enable {

    olympus = {
      desktop = {
        niri = enabled;
        noctalia = enabled;
      };
      services = {
        xdg = enabled;
      };
    };
  };
}
