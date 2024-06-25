{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    settings = {
      #Keybinds
      bind = [
        "$mainMod, return, exec, $terminal"
        "$mainMod, F, exec, $browser"
        "$mainMod, S, exec, $file_manager"
        "$mainMod, Q, killactive"
        #"$mainMod, P, pseudo"
        "$mainMod SHIFT, R, exec, hyprctl reload"

        "$mainMod, A, exec, loginctl lock-session"
        "$mainMod SHIFT, Q, exec, ${builtins.toString ./.}/scripts/powermenu.sh"
        "SUPER, SUPER_L, exec, rofi -show drun -theme ~/.config/rofi/launch.rasi"
        "$mainMod, D, exec, rofi -show drun -theme ~/.config/rofi/launch.rasi"

        # Windows
        "$mainMod, J, movefocus, d"
        "$mainMod, K, movefocus, u"
        "$mainMod, H, movefocus, l"
        "$mainMod, L, movefocus, r"
        "$mainMod SHIFT,J,movewindow,d"
        "$mainMod SHIFT,K,movewindow,u"
        "$mainMod SHIFT,H,movewindow,l"
        "$mainMod SHIFT,L,movewindow,r"
        "$mainMod, M, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ] ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (builtins.genList (
          x: let
            ws = let
              c = (x + 1) / 10;
            in
              builtins.toString (x + 1 - (c * 10));
          in [
            "$mainMod, ${ws}, workspace, ${toString (x + 1)}"
            "$mainMod SHIFT, ${ws}, movetoworkspacesilent, ${toString (x + 1)}"
          ]
        )
          10)
      );

      bindl = [
        # Volume
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
      ];

      bindle = [
        # Volume
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise --max-volume 120"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower --max-volume 120"
        ", XF86InputRaiseVolume, exec, swayosd-client --input-volume raise"
        ", XF86InputLowerVolume, exec, swayosd-client --input-volume lower"

        # Brightness
        ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise && brightnessctl -m | cut -d ',' -f3 > ~/.config/lock/bright"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower && brightnessctl -m | cut -d ',' -f3 > ~/.config/lock/bright"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
