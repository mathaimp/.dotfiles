{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.gdm;
in
{
  options.${namespace}.services.gdm = with types; {
    enable = mkBoolOpt false "Enable gdm";
  };

  config = mkIf cfg.enable {
    services.displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };
}
