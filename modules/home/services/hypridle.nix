{
  flake.homeModules.hypridle =
    { config, ... }:
    let
      # hypridle itself is compositor-agnostic; only DPMS control differs.
      dpms =
        state:
        if config.wayland.windowManager.hyprland.enable then
          "hyprctl dispatch dpms ${state}"
        else
          "niri msg action power-${state}-monitors";
    in
    {
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
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
