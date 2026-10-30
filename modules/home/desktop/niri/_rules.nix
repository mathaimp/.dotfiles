let
  floatBottomRight = {
    open-floating = true;
    default-floating-position._props = {
      x = 32;
      y = 32;
      relative-to = "bottom-right";
    };
  };
  matchAll = key: values: map (v: { match._props.${key} = v; }) values;
in
{
  # Window rules are order-sensitive, so they go in `_children`.
  wayland.windowManager.niri.settings._children = map (rule: { window-rule = rule; }) [
    {
      draw-border-with-background = false;
      geometry-corner-radius = 14.0;
      clip-to-geometry = true;
    }

    { open-maximized = true; }

    ({ match._props.title = "Picture in picture"; } // floatBottomRight)

    ({ match._props.title = "Discord Popout"; } // floatBottomRight)

    {
      _children = matchAll "app-id" [
        "pavucontrol"
        "pavucontrol-qt"
        "com.saivert.pwvucontrol"
      ];
      open-floating = true;
    }

    {
      _children = matchAll "app-id" [
        "nm-connection-editor"
        "blueman-manager"
      ];
      open-floating = true;
    }

    {
      _children = matchAll "app-id" [
        "xdg-desktop-portal-gtk"
        "gcr-prompter"
        "pinentry"
      ];
      open-floating = true;
    }

    {
      _children = matchAll "title" [
        "Properties"
        "Authentication Required"
        "Notice"
        "Warning"
        "Error"
      ];
      open-floating = true;
    }

    {
      match._props.app-id = "org.telegram.desktop";
      block-out-from = "screencast";
    }
  ];
}
