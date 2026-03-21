{
  config,
  lib,
  libEx,
  namespace,
  ...
}:
with lib;
with libEx.${namespace};
let
  cfg = config.${namespace}.desktop.hyprland.keybinds;
in
{
  options.${namespace}.desktop.hyprland.keybinds = with types; {
    enable = mkBoolOpt false "Enable hyprland keybinds";
  };
  config = mkIf cfg.enable {

    wayland.windowManager.hyprland = {
      settings = {
        #Keybinds
        bind = [
          "$mainMod, return, exec, $terminal"
          "$mainMod, F, exec, $browser"
          "$mainMod, D, exec, $file_manager"
          "$mainMod, Q, killactive"
          #"$mainMod, P, pseudo"
          "$mainMod SHIFT, R, exec, hyprctl reload"
          "$mainMod, E, fullscreen"
          ", PRINT, exec, grimshot savecopy anything"

          "$mainMod, A, exec, noctalia-shell ipc call lockScreen lock"
          "$mainMod SHIFT, Q, exec, noctalia-shell ipc call sessionMenu toggle"
          "SUPER, SUPER_L, exec, noctalia-shell ipc call launcher toggle"
          # "$mainMod, D, exec, rofi -show drun -theme ~/.config/rofi/launch.rasi"
          "$mainMod, V, exec, noctalia-shell ipc call launcher clipboard"

          # Windows
          "$mainMod, J, movefocus, d"
          "$mainMod, K, movefocus, u"
          "$mainMod, H, movefocus, l"
          "$mainMod, L, movefocus, r"
          "$mainMod SHIFT,J,movewindow,d"
          "$mainMod SHIFT,K,movewindow,u"
          "$mainMod SHIFT,H,movewindow,l"
          "$mainMod SHIFT,L,movewindow,r"
          "$mainMod, T, togglefloating"
          "$mainMod, S, togglespecialworkspace, magic"
          "$mainMod SHIFT, S, movetoworkspace, special:magic"
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (
            builtins.genList (
              x:
              let
                ws =
                  let
                    c = (x + 1) / 10;
                  in
                  toString (x + 1 - (c * 10));
              in
              [
                "$mainMod, ${ws}, workspace, ${toString (x + 1)}"
                "$mainMod SHIFT, ${ws}, movetoworkspacesilent, ${toString (x + 1)}"
              ]
            ) 10
          )
        );

        bindl = [
          # Volume
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ];
        bindle = [
          # Volume
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          # Brightness
          ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      };
    };
  };
}
