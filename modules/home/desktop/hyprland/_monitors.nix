{ lib, ... }:
let
  workspacesOn =
    monitor: range:
    map (ws: {
      workspace = toString ws;
      inherit monitor;
    }) range;
in
{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      {
        output = "eDP-1";
        mode = "1920x1080@144";
        position = "0x0";
        scale = 1;
      }
      {
        output = "HDMI-A-1";
        mode = "1920x1080@74.97";
        position = "1920x0";
        scale = 1;
      }
    ];

    workspace_rule = workspacesOn "eDP-1" (lib.range 1 5) ++ workspacesOn "HDMI-A-1" (lib.range 6 10);
  };
}
