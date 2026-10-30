{ lib, config, ... }:
let
  inherit (lib.generators) mkLuaInline toLua;

  mod = "SUPER";
  terminalChoice =
    if config.programs.kitty.enable then
      "kitty"
    else if config.programs.ghostty.enable then
      "ghostty"
    else
      "xterm";

  # bind "KEY" "<hl.dsp expression>" [ { locked = true; } ] -> hl.bind("KEY", <expr>, { ... })
  bind = key: dsp: opts: {
    _args = [
      key
      (mkLuaInline dsp)
    ]
    ++ opts;
  };
  exec = cmd: "hl.dsp.exec_cmd(${toLua { } cmd})";
  # Media/brightness keys keep working on the lock screen.
  locked = [ { locked = true; } ];
  lockedRepeat = [
    {
      locked = true;
      repeating = true;
    }
  ];

  workspaceBinds = lib.concatMap (
    ws:
    let
      key = toString (if ws == 10 then 0 else ws);
    in
    [
      (bind "${mod} + ${key}" "hl.dsp.focus({ workspace = ${toString ws} })" [ ])
      (bind "${mod} + SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${toString ws} })" [ ])
    ]
  ) (lib.range 1 10);
in
{
  wayland.windowManager.hyprland.settings.bind = [
    # Apps
    (bind "${mod} + RETURN" (exec terminalChoice) [ ])
    (bind "${mod} + F" (exec "firefox") [ ])
    (bind "${mod} + D" (exec "nautilus") [ ])

    # Window control
    (bind "${mod} + Q" "hl.dsp.window.close()" [ ])
    (bind "${mod} + E" ''hl.dsp.window.fullscreen({ action = "toggle", mode = "maximized" })'' [ ])
    (bind "${mod} + T" ''hl.dsp.window.float({ action = "toggle" })'' [ ])
    (bind "${mod} + SHIFT + R" (exec "hyprctl reload") [ ])

    # Screenshot
    (bind "PRINT" (exec "grimshot savecopy anything") [ ])

    # Session / Noctalia
    (bind "${mod} + A" (exec "loginctl lock-session") [ ])
    (bind "${mod} + SHIFT + Q" (exec "wlogout -b 6") [ ])
    (bind "${mod} + SPACE" (exec "qs -c default ipc call launcher toggle") [ ])
    (bind "${mod} + V" (exec "noctalia msg panel-toggle clipboard") [ ])
    (bind "${mod} + C" (exec "qs -c default ipc call quicksettings toggle") [ ])

    # Focus
    (bind "${mod} + H" ''hl.dsp.focus({ direction = "left" })'' [ ])
    (bind "${mod} + J" ''hl.dsp.focus({ direction = "down" })'' [ ])
    (bind "${mod} + K" ''hl.dsp.focus({ direction = "up" })'' [ ])
    (bind "${mod} + L" ''hl.dsp.focus({ direction = "right" })'' [ ])

    # Move window
    (bind "${mod} + SHIFT + H" ''hl.dsp.window.move({ direction = "left" })'' [ ])
    (bind "${mod} + SHIFT + J" ''hl.dsp.window.move({ direction = "down" })'' [ ])
    (bind "${mod} + SHIFT + K" ''hl.dsp.window.move({ direction = "up" })'' [ ])
    (bind "${mod} + SHIFT + L" ''hl.dsp.window.move({ direction = "right" })'' [ ])

    # Scratchpad
    (bind "${mod} + S" ''hl.dsp.workspace.toggle_special("magic")'' [ ])
    (bind "${mod} + SHIFT + S" ''hl.dsp.window.move({ workspace = "special:magic" })'' [ ])

    # Mouse
    (bind "${mod} + mouse:272" "hl.dsp.window.drag()" [ { mouse = true; } ])
    (bind "${mod} + mouse:273" "hl.dsp.window.resize()" [ { mouse = true; } ])

    # Media
    (bind "XF86AudioPlay" (exec "swayosd-client --playerctl play-pause") locked)
    (bind "XF86AudioPrev" (exec "swayosd-client --playerctl previous") locked)
    (bind "XF86AudioNext" (exec "swayosd-client --playerctl next") locked)
    (bind "XF86AudioMute" (exec "swayosd-client --output-volume mute-toggle") locked)
    (bind "XF86AudioMicMute" (exec "swayosd-client --input-volume mute-toggle") locked)
    (bind "XF86AudioRaiseVolume" (exec "swayosd-client --output-volume raise") lockedRepeat)
    (bind "XF86AudioLowerVolume" (exec "swayosd-client --output-volume lower") lockedRepeat)

    # Brightness
    (bind "XF86MonBrightnessUp" (exec "swayosd-client --brightness raise") lockedRepeat)
    (bind "XF86MonBrightnessDown" (exec "swayosd-client --brightness lower") lockedRepeat)
  ]
  ++ workspaceBinds;
}
