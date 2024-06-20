{config, pkgs, lib, inputs, ... }:
{

  home.packages = with pkgs; [
    swww
    swayosd
    playerctl
  ];

  services.playerctld.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {

      "$terminal" = "wezterm";
      "$browser" = "firefox";
      "$mainMod" = "SUPER";

      input.numlock_by_default = true;

      exec-once = [
        "swww-daemon"
        "swayosd-server"
      ];

      exec = [
        "swww img ${config.stylix.image}"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      ];

      misc.disable_hyprland_logo = true;
      misc.disable_splash_rendering = true;

      bind = [
        "$mainMod, return, exec, $terminal"
        "$mainMod, W, exec, $browser"

        # Windows
        "$mainMod, J, movefocus, d"
        "$mainMod, K, movefocus, u"
        "$mainMod, H, movefocus, l"
        "$mainMod, L, movefocus, r"
        "SUPER_SHIFT,J,movewindow,d"
        "SUPER_SHIFT,K,movewindow,u"
        "SUPER_SHIFT,H,movewindow,l"
        "SUPER_SHIFT,L,movewindow,r"
        "$mainMod, S, togglespecialworkspace, magic"
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
        ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
