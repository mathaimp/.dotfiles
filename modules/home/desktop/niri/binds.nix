{
  config,
  namespace,
  pkgs,
  ...
}:
let
  noctalia =
    cmd:
    [
      "noctalia-shell"
      "ipc"
      "call"
    ]
    ++ (pkgs.lib.splitString " " cmd);
  terminalChoice =
    if config.${namespace}.programs.kitty.enable then
      "kitty"
    else if config.${namespace}.programs.ghostty.enable then
      "ghostty"
    else
      "xterm"; # fallback

in
{
  programs.niri.settings.binds = with config.lib.niri.actions; {
    "Mod+Shift+Slash".action = show-hotkey-overlay;

    "Mod+Return".action = spawn [ "${terminalChoice}" ];
    "Mod+F".action = spawn [ "firefox" ];
    "Mod+D".action = spawn [ "nautilus" ];

    "Mod+Q".action = close-window;
    "Mod+Shift+R".action = spawn [
      "niri"
      "msg"
      "reload"
    ];
    "Mod+W".action = toggle-window-floating;
    "Alt+Return".action = fullscreen-window;

    "Mod+A".action.spawn = noctalia "lockScreen lock";
    "Mod+Shift+Q".action.spawn = noctalia "sessionMenu toggle";

    "Mod+Space".action.spawn = noctalia "launcher toggle";

    "Mod+Tab".action.spawn = noctalia "launcher windows";

    "Mod+M".action = maximize-column;

    "Mod+H".action = focus-monitor-left;
    "Mod+J".action = focus-workspace-down;
    "Mod+K".action = focus-workspace-up;
    "Mod+L".action = focus-monitor-right;

    "Mod+Left".action = focus-column-left;
    "Mod+Right".action = focus-column-right;
    "Mod+Up".action = focus-window-up;
    "Mod+Down".action = focus-window-down;

    "Mod+Shift+H".action = focus-column-left;
    "Mod+Shift+L".action = focus-column-right;

    "Mod+Shift+1".action.move-column-to-workspace = 1;
    "Mod+Shift+2".action.move-column-to-workspace = 2;
    "Mod+Shift+3".action.move-column-to-workspace = 3;
    "Mod+Shift+4".action.move-column-to-workspace = 4;
    "Mod+Shift+5".action.move-column-to-workspace = 5;
    "Mod+Shift+6".action.move-column-to-workspace = 6;
    "Mod+Shift+7".action.move-column-to-workspace = 7;
    "Mod+Shift+8".action.move-column-to-workspace = 8;
    "Mod+Shift+9".action.move-column-to-workspace = 9;
    "Mod+Shift+0".action.move-column-to-workspace = 10;

    "Mod+1".action.focus-workspace = 1;
    "Mod+2".action.focus-workspace = 2;
    "Mod+3".action.focus-workspace = 3;
    "Mod+4".action.focus-workspace = 4;
    "Mod+5".action.focus-workspace = 5;
    "Mod+6".action.focus-workspace = 6;
    "Mod+7".action.focus-workspace = 7;
    "Mod+8".action.focus-workspace = 8;
    "Mod+9".action.focus-workspace = 9;
    "Mod+0".action.focus-workspace = 10;

    "Mod+V".action.spawn = noctalia "launcher clipboard";

    "Print".action = spawn [
      "niri"
      "msg"
      "action"
      "screenshot"
    ];
    "Mod+P".action = spawn [
      "niri"
      "msg"
      "action"
      "screenshot"
    ];
    "Mod+Alt+P".action = spawn [
      "niri"
      "msg"
      "action"
      "screenshot-screen"
    ];

    "Mod+Shift+Right".action = set-column-width "+30";
    "Mod+Shift+Left".action = set-column-width "-30";
    "Mod+Shift+Up".action = set-window-height "+30";
    "Mod+Shift+Down".action = set-window-height "-30";

    "Mod+WheelScrollDown".action = focus-workspace-up;
    "Mod+WheelScrollDown".cooldown-ms = 150;
    "Mod+WheelScrollUp".action = focus-workspace-down;
    "Mod+WheelScrollUp".cooldown-ms = 150;

    "Mod+Ctrl+WheelScrollDown".action = move-column-to-workspace-up;
    "Mod+Ctrl+WheelScrollDown".cooldown-ms = 150;
    "Mod+Ctrl+WheelScrollUp".action = move-column-to-workspace-down;
    "Mod+Ctrl+WheelScrollUp".cooldown-ms = 150;

    "XF86AudioPlay".action = spawn [
      "playerctl"
      "play-pause"
    ];
    "XF86AudioPrev".action = spawn [
      "playerctl"
      "previous"
    ];
    "XF86AudioPause".action = spawn [
      "playerctl"
      "play-pause"
    ];
    "XF86AudioNext".action = spawn [
      "playerctl"
      "next"
    ];

    "XF86AudioRaiseVolume".action = spawn [
      "wpctl"
      "set-volume"
      "@DEFAULT_AUDIO_SINK@"
      "5%+"
    ];
    "XF86AudioRaiseVolume".allow-when-locked = true;
    "XF86AudioLowerVolume".action = spawn [
      "wpctl"
      "set-volume"
      "@DEFAULT_AUDIO_SINK@"
      "5%-"
    ];
    "XF86AudioLowerVolume".allow-when-locked = true;
    "XF86AudioMute".action = spawn [
      "wpctl"
      "set-mute"
      "@DEFAULT_AUDIO_SINK@"
      "toggle"
    ];
    "XF86AudioMute".allow-when-locked = true;
    "XF86AudioMicMute".action = spawn [
      "wpctl"
      "set-mute"
      "@DEFAULT_AUDIO_SOURCE@"
      "toggle"
    ];
    "XF86AudioMicMute".allow-when-locked = true;
    "XF86MonBrightnessUp".action = spawn [
      "brightnessctl"
      "set"
      "5%+"
    ];
    "XF86MonBrightnessUp".allow-when-locked = true;
    "XF86MonBrightnessDown".action = spawn [
      "brightnessctl"
      "set"
      "5%-"
    ];

    "Ctrl+Alt+Delete".action = quit;
    "Mod+Shift+P".action = power-off-monitors;
  };
}
