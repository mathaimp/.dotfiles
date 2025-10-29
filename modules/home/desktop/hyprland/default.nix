{ options, osConfig, config, lib, pkgs, inputs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.hyprland;
  stylixColors = osConfig.lib.stylix.colors;
in
{
  options.${namespace}.desktop.hyprland = with types; {
    enable = mkBoolOpt false "Enable hyprland";
  };
  config = mkIf cfg.enable {

    olympus.desktop.hyprland = { keybinds = enabled; };

    services.playerctld.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd.enable = false; # Don't use with USWM
      settings = {

        "$terminal" = "kitty";
        "$browser" = "firefox";
        "$file_manager" = "thunar";
        "$mainMod" = "ALT";

        input.numlock_by_default = true;

        exec-once = [
          "swww-daemon"
          "swayosd-server"
          "waybar"
          "swaync"
          "nm-applet"
          "clipse -listen"
          "[workspace special:magic silent] keepassxc"
        ];

        env = [
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
        ];

        exec = [ "swww img ${osConfig.stylix.image}" ];

        layerrule = [ "blur,waybar" ];
        windowrule = [
          "opacity 0.95 override 0.95 override 0.95 override, class:kitty"

          "float, class:org.keepassxc.KeePassXC"

          "float, class:(clipse)"
          "size 622 652, class:(clipse)"
          "stayfocused, class:(clipse)"
        ];

        general.gaps_out = 6;
        general.gaps_in = 3;
        general."col.active_border" = lib.mkForce "rgb(${stylixColors.base03})";
        general."col.inactive_border" =
          lib.mkForce "rgb(${stylixColors.base02})";

        input.kb_options = "ctrl:nocaps";
        decoration.blur.enabled = true;
        decoration.rounding = 10;

        misc.vfr = true;
        misc.disable_hyprland_logo = true;
        misc.disable_splash_rendering = true;
        misc.mouse_move_enables_dpms = true;
        misc.key_press_enables_dpms = true;

      };
    };
  };
}
