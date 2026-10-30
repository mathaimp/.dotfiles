{ osConfig, ... }:
{
  wayland.windowManager.niri.settings = {
    spawn-at-startup = "noctalia";

    input = {
      keyboard = {
        xkb.layout = "us";
        numlock = { };
      };
      touchpad = {
        tap = { };
        natural-scroll = { };
      };
      focus-follows-mouse._props.max-scroll-amount = "0.0%";
    };

    prefer-no-csd = { };

    layout = {
      gaps = 10;
      center-focused-column = "never";

      preset-column-widths._children = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
      ];

      default-column-width.proportion = 0.5;

      focus-ring.off = { };

      border = {
        width = 2;
        active-color = "#${osConfig.lib.stylix.colors.base03}";
        inactive-color = "#${osConfig.lib.stylix.colors.base02}";
      };

      shadow.off = { };
    };

    hotkey-overlay.skip-at-startup = { };

    environment = {
      NIXOS_OZONE_WL = "1";
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_DESKTOP = "niri";
    };

    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

    animations.slowdown = 1.0;

    overview = {
      zoom = 0.5;
      workspace-shadow.off = { };
    };

    gestures.hot-corners.off = { };

    debug.honor-xdg-activation-with-invalid-serial = { };
  };
}
