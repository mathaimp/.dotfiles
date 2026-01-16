{
  osConfig,
  config,
  lib,
  libEx,
  namespace,
  ...
}:
with lib;
with libEx.${namespace};
let
  cfg = config.${namespace}.desktop.hyprland;
  stylixEnabled = config.${namespace}.programs.stylix.enable or false;
  stylixColors = if stylixEnabled then osConfig.lib.stylix.colors else null;
  stylixWallpaper = if stylixEnabled then osConfig.stylix.image else null;
  terminalChoice =
    if config.${namespace}.programs.kitty.enable then
      "kitty"
    else if config.${namespace}.programs.ghostty.enable then
      "ghostty"
    else
      "xterm"; # fallback
in
{
  options.${namespace}.desktop.hyprland = with types; {
    enable = mkBoolOpt false "Enable hyprland";
  };
  config = mkIf cfg.enable {

    olympus.desktop.hyprland = {
      keybinds = enabled;
    };

    services.playerctld.enable = true;
    services.swayosd.enable = true;
    services.clipse.enable = true;
    services.network-manager-applet.enable = true;

    services.hyprpaper = {
      enable = true;
      settings = {
        splash = false;
        preload = [ stylixWallpaper ];
        wallpaper = [ stylixWallpaper ];
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      settings = {
        "$terminal" = terminalChoice;
        "$browser" = "firefox";
        "$file_manager" = "nautilus";
        "$mainMod" = "ALT";

        input.numlock_by_default = true;

        exec-once = [
          "waybar"
        ];

        env = [
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "NIXOS_OZONE_WL,1"
        ];


        windowrule = [
          "float on, match:class com.save.clipse"
          "size 622 652, match:class com.save.clipse"
          "stay_focused on, match:class com.save.clipse"
        ];

        general.gaps_out = 6;
        general.gaps_in = 3;
        general.border_size = 2;
        general."col.active_border" = lib.mkForce "rgb(${stylixColors.base03})";
        general."col.inactive_border" = lib.mkForce "rgb(${stylixColors.base02})";

        animation = [
          "windows,1,4,default"
          "windowsOut,1,4,default"
          "border,1,2,default"
          "fade,1,0.5,default"
          "fadeDim,1,0.5,default"
          "workspaces,1,3,default"
        ];

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
