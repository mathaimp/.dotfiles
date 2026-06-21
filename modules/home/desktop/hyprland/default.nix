{
  flake.homeModules.hyprland =
    { osConfig
    , pkgs
    , ...
    }:
    let
      stylixColors = osConfig.lib.stylix.colors;
      stylixWallpaper = osConfig.stylix.image;
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
        configType = "lua";
        extraConfig = ''
          hl.on("hyprland.start", function()
            hl.exec_cmd("noctalia-shell")
          end)

          hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
          hl.env("XDG_SESSION_TYPE",    "wayland")
          hl.env("XDG_SESSION_DESKTOP", "Hyprland")
          hl.env("NIXOS_OZONE_WL",      "1")

          hl.workspace_rule({ workspace = "1", persistent = true })
          hl.workspace_rule({ workspace = "2", persistent = true })
          hl.workspace_rule({ workspace = "3", persistent = true })
          hl.workspace_rule({ workspace = "4", persistent = true })
          hl.workspace_rule({ workspace = "5", persistent = true })

          hl.config({
            input = {
              numlock_by_default = true,
              kb_options = "ctrl:nocaps",
            },
            general = {
              gaps_out = 6,
              gaps_in = 3,
              border_size = 2,
              col = {
                active_border   = "rgb(${stylixColors.base03})",
                inactive_border = "rgb(${stylixColors.base02})",
              },
            },
            decoration = {
              rounding = 10,
              blur = {
                enabled = true,
              },
            },
            misc = {
              disable_hyprland_logo    = true,
              disable_splash_rendering = true,
              mouse_move_enables_dpms  = true,
              key_press_enables_dpms   = true,
            },
          })

          hl.animation({ leaf = "windows",    enabled = true, speed = 4, bezier = "default" })
          hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "default" })
          hl.animation({ leaf = "border",     enabled = true, speed = 2, bezier = "default" })
          hl.animation({ leaf = "fade",       enabled = true, speed = 2, bezier = "default" })
          hl.animation({ leaf = "fadeDim",    enabled = true, speed = 2, bezier = "default" })
          hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "default" })
        '';
      };
    };
}
