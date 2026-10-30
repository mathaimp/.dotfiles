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
  # What is enabled decides which binds exist (the default apps come from preferences.nix).
  apps = config.preferences;
  osd = config.services.swayosd.enable;
  shell = config.programs.quickshell.enable;

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
  wayland.windowManager.niri.settings.binds =
    workspaceBinds
    // {
    "Mod+Shift+Slash".show-hotkey-overlay = { };

    "Mod+Q".close-window = { };
    "Mod+Shift+R".spawn = [
      "niri"
      "msg"
      "reload"
    ];
    "Mod+W".toggle-window-floating = { };
    "Alt+Return".fullscreen-window = { };

    "Mod+A".spawn-sh = "loginctl lock-session";
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

    "Ctrl+Alt+Delete".quit = { };
    "Mod+Shift+P".power-off-monitors = { };
  }
  // lib.optionalAttrs (apps.terminal != null) {
    "Mod+Return".spawn = apps.terminal;
  }
  // lib.optionalAttrs (apps.browser != null) {
    "Mod+F".spawn = apps.browser;
  }
  // lib.optionalAttrs (apps.fileManager != null) {
    "Mod+D".spawn = apps.fileManager;
  }
  // lib.optionalAttrs config.programs.wlogout.enable {
    "Mod+Shift+Q".spawn-sh = "wlogout -b 6";
  }
  // lib.optionalAttrs shell {
    "Mod+Space".spawn-sh = "qs -c default ipc call launcher toggle";
    "Mod+C".spawn-sh = "qs -c default ipc call quicksettings toggle";
  }
  # Clipboard history (clipse). Unlike Hyprland, no float rule is set for it here.
  // lib.optionalAttrs (config.services.clipse.enable && apps.terminal != null) {
    "Mod+V".spawn = [
      apps.terminal
      "--class=com.save.clipse"
      "-e"
      "clipse"
    ];
  }
  // lib.optionalAttrs osd {
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
      spawn-sh = "swayosd-client --brightness +5" + lib.optionalString shell "; qs -c default ipc call brightness stepExternal 0.05";
    };
    "XF86MonBrightnessDown" = {
      _props.allow-when-locked = true;
      spawn-sh = "swayosd-client --brightness -5" + lib.optionalString shell "; qs -c default ipc call brightness stepExternal -0.05";
    };
  };
}
