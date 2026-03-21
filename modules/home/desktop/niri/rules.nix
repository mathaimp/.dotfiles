{ ... }:
{
  programs.niri.settings.window-rules = [
    {
      draw-border-with-background = false;
      geometry-corner-radius =
        let
          r = 14.0;
        in
        {
          top-left = r;
          top-right = r;
          bottom-left = r;
          bottom-right = r;
        };
      clip-to-geometry = true;
    }

    { open-maximized = true; }

    {
      matches = [ { title = "Picture in picture"; } ];
      open-floating = true;
      default-floating-position = {
        x = 32;
        y = 32;
        relative-to = "bottom-right";
      };
    }

    {
      matches = [ { title = "Discord Popout"; } ];
      open-floating = true;
      default-floating-position = {
        x = 32;
        y = 32;
        relative-to = "bottom-right";
      };
    }

    {
      matches = [
        { app-id = "pavucontrol"; }
        { app-id = "pavucontrol-qt"; }
        { app-id = "com.saivert.pwvucontrol"; }
      ];
      open-floating = true;
    }

    {
      matches = [
        { app-id = "nm-connection-editor"; }
        { app-id = "blueman-manager"; }
      ];
      open-floating = true;
    }

    {
      matches = [
        { app-id = "xdg-desktop-portal-gtk"; }
        { app-id = "gcr-prompter"; }
        { app-id = "pinentry"; }
      ];
      open-floating = true;
    }

    {
      matches = [
        { title = "Properties"; }
        { title = "Authentication Required"; }
        { title = "Notice"; }
        { title = "Warning"; }
        { title = "Error"; }
      ];
      open-floating = true;
    }

    {
      matches = [ { app-id = "org.telegram.desktop"; } ];
      block-out-from = "screencast";
    }
  ];
}
