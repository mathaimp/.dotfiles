{
  flake.homeModules.hypridle =
    { config, ... }:
    let
      wm = config.wayland.windowManager;
      # hypridle itself is compositor-agnostic; only DPMS control differs.
      dpms =
        state:
        if wm.hyprland.enable then
          "hyprctl dispatch dpms ${state}"
        else if wm.niri.enable then
          "niri msg action power-${state}-monitors"
        else
          "true"; # no known compositor: nothing to switch
      # Prefer hyprlock when it is set up; otherwise leave locking to whatever handles the session lock.
      lock =
        if config.programs.hyprlock.enable then "pidof hyprlock || hyprlock" else "loginctl lock-session";
    in
    {
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = lock;
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = dpms "on";
          };
          listener = [
            {
              timeout = 600;
              on-timeout = "brightnessctl -s set 0";
              on-resume = "brightnessctl -r";
            }
            {
              timeout = 630;
              on-timeout = dpms "off";
              on-resume = dpms "on";
            }
            {
              timeout = 660;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 900;
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };
    };
}
