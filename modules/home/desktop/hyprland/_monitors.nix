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

    workspace_rule = [
      {
        workspace = "1";
        monitor = "eDP-1";
      }
      {
        workspace = "3";
        monitor = "eDP-1";
      }
      {
        workspace = "5";
        monitor = "eDP-1";
      }
      {
        workspace = "7";
        monitor = "eDP-1";
      }
      {
        workspace = "9";
        monitor = "eDP-1";
      }

      {
        workspace = "2";
        monitor = "HDMI-A-1";
      }
      {
        workspace = "4";
        monitor = "HDMI-A-1";
      }
      {
        workspace = "6";
        monitor = "HDMI-A-1";
      }
      {
        workspace = "8";
        monitor = "HDMI-A-1";
      }
      {
        workspace = "10";
        monitor = "HDMI-A-1";
      }
    ];
  };
}
