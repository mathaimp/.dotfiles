{
  flake.homeModules.hyprland =
    {
      osConfig,
      config,
      lib,
      pkgs,
      ...
    }:
    let
      stylixColors = osConfig.lib.stylix.colors;
      stylixWallpaper = osConfig.stylix.image;
      terminalChoice =
        if config.programs.kitty.enable then
          "kitty"
        else if config.programs.ghostty.enable then
          "ghostty"
        else
          "xterm"; # fallback
    in
    {
      imports = [
        ./_keybinds.nix
      ];

      home.packages = with pkgs; [
        wl-clipboard
        brightnessctl
        sway-contrib.grimshot
      ];

      services = {
        playerctld.enable = true;

        hyprpaper = {
          enable = true;
          settings = {
            splash = false;
            preload = [ stylixWallpaper ];
            wallpaper = [ stylixWallpaper ];
          };
        };

      };

      wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;
        settings = {

          "$terminal" = terminalChoice;
          "$browser" = "firefox";
          "$file_manager" = "nautilus";
          "$mainMod" = "SUPER";

          exec-once = [ "noctalia-shell" ];

          input.numlock_by_default = true;

          workspace = builtins.genList (x: "${toString (x + 1)}, persistent:true") 5;

          env = [
            "XDG_CURRENT_DESKTOP,Hyprland"
            "XDG_SESSION_TYPE,wayland"
            "XDG_SESSION_DESKTOP,Hyprland"
            "NIXOS_OZONE_WL,1"
          ];

          general = {
            gaps_out = 6;
            gaps_in = 3;
            border_size = 2;
            "col.active_border" = lib.mkForce "rgb(${stylixColors.base03})";
            "col.inactive_border" = lib.mkForce "rgb(${stylixColors.base02})";
          };
          animation = [
            "windows,1,4,default"
            "windowsOut,1,4,default"
            "border,1,2,default"
            "fade,1,0.5,default"
            "fadeDim,1,0.5,default"
            "workspaces,1,3,default"
          ];

          input.kb_options = "ctrl:nocaps";
          decoration.blur.enabled = true;
          decoration.rounding = 10;

          misc = {
            vfr = true;
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            mouse_move_enables_dpms = true;
            key_press_enables_dpms = true;
          };
        };
      };
    };
}
