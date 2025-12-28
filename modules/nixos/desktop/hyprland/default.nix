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
  cfg = config.${namespace}.desktop.hyprland;
in
{
  options.${namespace}.desktop.hyprland = with types; {
    enable = mkBoolOpt false "Whether or not to use Hyprland as the desktop environment.";
  };

  config = mkIf cfg.enable {
    environment = {
      sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
    };
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    services = {
      gvfs.enable = true;
      devmon.enable = true;
      upower.enable = true;
    };

    olympus = {
      programs = {
        # thunar = enabled;
        nautilus = enabled;
      };
      services = {
        gdm = enabled;
        polkit-gnome = enabled;
        xdg = enabled;
      };
    };
  };
}
