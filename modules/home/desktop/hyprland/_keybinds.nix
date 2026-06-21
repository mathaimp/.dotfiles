{ lib, config, ... }:
let
  terminalChoice =
    if config.programs.kitty.enable then
      "kitty"
    else if config.programs.ghostty.enable then
      "ghostty"
    else
      "xterm";

  workspaceBinds = lib.concatMapStrings
    (
      x:
      let
        ws = toString (x + 1);
        key = toString (if x + 1 == 10 then 0 else x + 1);
      in
      ''
        hl.bind("SUPER + ${key}", hl.dsp.focus({ workspace = ${ws} }))
        hl.bind("SUPER + SHIFT + ${key}", hl.dsp.window.move({ workspace = ${ws} }))
      ''
    )
    (lib.range 0 9);
in
{
  wayland.windowManager.hyprland.extraConfig = ''
    local mainMod = "SUPER"

    -- Apps
    hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("${terminalChoice}"))
    hl.bind(mainMod .. " + F",      hl.dsp.exec_cmd("firefox"))
    hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd("nautilus"))

    -- Window control
    hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
    hl.bind(mainMod .. " + E",         hl.dsp.window.fullscreen())
    hl.bind(mainMod .. " + T",         hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))

    -- Screenshot
    hl.bind("PRINT", hl.dsp.exec_cmd("grimshot savecopy anything"))

    -- Noctalia
    hl.bind(mainMod .. " + A",         hl.dsp.exec_cmd("noctalia-shell ipc call lockScreen lock"))
    hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("noctalia-shell ipc call sessionMenu toggle"))
    hl.bind(mainMod .. " + SPACE",     hl.dsp.exec_cmd("noctalia-shell ipc call launcher toggle"))
    hl.bind(mainMod .. " + V",         hl.dsp.exec_cmd("noctalia-shell ipc call launcher clipboard"))

    -- Focus
    hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
    hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
    hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
    hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

    -- Move window
    hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
    hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
    hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
    hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

    -- Scratchpad
    hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
    hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

    -- Workspaces
    ${workspaceBinds}

    -- Mouse
    hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
    hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

    -- Media
    hl.bind("XF86AudioPlay",    hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPrev",    hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
    hl.bind("XF86AudioNext",    hl.dsp.exec_cmd("playerctl next"),       { locked = true })
    hl.bind("XF86AudioMute",    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true })
    hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),   { locked = true, repeating = true })
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })


    -- Brightness
    hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
  '';
}
