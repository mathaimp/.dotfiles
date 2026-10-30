{
  config,
  lib,
  ...
}:
let
  swayosd = args: {
    _props.allow-when-locked = true;
    spawn = [ "swayosd-client" ] ++ args;
  };
  # Mouse wheel binds need a cooldown so one scroll doesn't skip many workspaces.
  wheel = action: {
    _props.cooldown-ms = 150;
    ${action} = { };
  };
  terminalChoice =
    if config.programs.kitty.enable then
      "kitty"
    else if config.programs.ghostty.enable then
      "ghostty"
    else
      "xterm"; # fallback

  workspaceBinds = lib.mergeAttrsList (
    map (
      x:
      let
        key = toString (if x == 10 then 0 else x);
      in
      {
        "Mod+${key}".focus-workspace = x;
        "Mod+Shift+${key}".move-column-to-workspace = x;
      }
    ) (lib.range 1 10)
  );
in
{
  wayland.windowManager.niri.settings.binds = workspaceBinds // {
    "Mod+Shift+Slash".show-hotkey-overlay = { };

    "Mod+Return".spawn = terminalChoice;
    "Mod+F".spawn = "firefox";
    "Mod+D".spawn = "nautilus";

    "Mod+Q".close-window = { };
    "Mod+Shift+R".spawn = [
      "niri"
      "msg"
      "reload"
    ];
    "Mod+W".toggle-window-floating = { };
    "Alt+Return".fullscreen-window = { };

    "Mod+A".spawn-sh = "loginctl lock-session";
    "Mod+Shift+Q".spawn-sh = "wlogout -b 6";

    "Mod+Space".spawn = [
      "qs"
      "-c"
      "default"
      "ipc"
      "call"
      "launcher"
      "toggle"
    ];
    # Clipboard history (clipse). Unlike Hyprland, no float rule is set for it here.
    "Mod+V".spawn = [
      "ghostty"
      "--class=com.save.clipse"
      "-e"
      "clipse"
    ];
    "Mod+C".spawn = [
      "qs"
      "-c"
      "default"
      "ipc"
      "call"
      "quicksettings"
      "toggle"
    ];

    "Mod+E".maximize-column = { };

    "Mod+H".focus-column-left = { };
    "Mod+J".focus-workspace-down = { };
    "Mod+K".focus-workspace-up = { };
    "Mod+L".focus-column-right = { };

    "Mod+Left".focus-column-left = { };
    "Mod+Right".focus-column-right = { };
    "Mod+Up".focus-window-up = { };
    "Mod+Down".focus-window-down = { };

    "Mod+Shift+H".move-column-left = { };
    "Mod+Shift+L".move-column-right = { };
    "Mod+Shift+J".move-window-down = { };
    "Mod+Shift+K".move-window-up = { };

    "Print".screenshot = { };
    "Mod+P".screenshot = { };
    "Mod+Alt+P".screenshot-screen = { };

    "Mod+Shift+Right".set-column-width = "+30";
    "Mod+Shift+Left".set-column-width = "-30";
    "Mod+Shift+Up".set-window-height = "+30";
    "Mod+Shift+Down".set-window-height = "-30";

    "Mod+WheelScrollDown" = wheel "focus-workspace-up";
    "Mod+WheelScrollUp" = wheel "focus-workspace-down";
    "Mod+Ctrl+WheelScrollDown" = wheel "move-column-to-workspace-up";
    "Mod+Ctrl+WheelScrollUp" = wheel "move-column-to-workspace-down";

    "XF86AudioPlay" = swayosd [
      "--playerctl"
      "play-pause"
    ];
    "XF86AudioPause" = swayosd [
      "--playerctl"
      "play-pause"
    ];
    "XF86AudioPrev" = swayosd [
      "--playerctl"
      "previous"
    ];
    "XF86AudioNext" = swayosd [
      "--playerctl"
      "next"
    ];

    "XF86AudioRaiseVolume" = swayosd [
      "--output-volume"
      "+5"
    ];
    "XF86AudioLowerVolume" = swayosd [
      "--output-volume"
      "-5"
    ];
    "XF86AudioMute" = swayosd [
      "--output-volume"
      "mute-toggle"
    ];
    "XF86AudioMicMute" = swayosd [
      "--input-volume"
      "mute-toggle"
    ];

    # swayosd-client moves the built-in panel; the shell moves external monitors by the same step.
    "XF86MonBrightnessUp" = {
      _props.allow-when-locked = true;
      spawn-sh = "swayosd-client --brightness +5; qs -c default ipc call brightness stepExternal 0.05";
    };
    "XF86MonBrightnessDown" = {
      _props.allow-when-locked = true;
      spawn-sh = "swayosd-client --brightness -5; qs -c default ipc call brightness stepExternal -0.05";
    };

    "Ctrl+Alt+Delete".quit = { };
    "Mod+Shift+P".power-off-monitors = { };
  };
}
