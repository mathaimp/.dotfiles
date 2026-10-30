{
  flake.homeModules.xdg =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      wm = config.wayland.windowManager;
    in
    {
      xdg.userDirs.setSessionVariables = true;
      xdg.portal = {
        enable = true;
        extraPortals =
          with pkgs;
          [
            xdg-desktop-portal-gtk
            xdg-desktop-portal-gnome
          ]
          ++ lib.optional wm.hyprland.enable xdg-desktop-portal-hyprland;

        # Portal choice per compositor, only for the compositors that are enabled.
        config = {
          common = {
            default = [ "gtk" ];
          };
        }
        // lib.optionalAttrs wm.niri.enable {
          niri = {
            default = [ "gnome" ];
          };
        }
        // lib.optionalAttrs wm.hyprland.enable {
          hyprland = {
            default = [
              "hyprland"
              "gtk"
            ];
          };
        };
      };
    };
}
