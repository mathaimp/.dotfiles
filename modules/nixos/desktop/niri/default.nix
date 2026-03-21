{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.niri;
in
{
  options.${namespace}.desktop.niri = with types; {
    enable = mkBoolOpt false "Whether or not to use Niri as the desktop environment.";
  };

  config = mkIf cfg.enable {
    programs.niri = {
      enable = true;
    };

    services = {
      gvfs.enable = true;
      devmon.enable = true;
      upower.enable = true;
    };

    olympus = {
      programs = {
        nautilus = enabled;
      };
      services = {
        gdm = enabled;
        polkit-gnome = enabled;
      };
    };
  };
}
