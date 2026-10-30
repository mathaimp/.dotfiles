{
  flake.homeModules.hyprland =
    {
      lib,
      osConfig,
      pkgs,
      ...
    }:
    let
      stylixColors = osConfig.lib.stylix.colors;
      stylixWallpaper = osConfig.stylix.image;
    in
    {
      imports = [
        ./_keybinds.nix
        ./_monitors.nix
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
        settings = {
          on = [
            {
              _args = [
                "hyprland.start"
                (lib.generators.mkLuaInline ''
                  function()
                    hl.exec_cmd("noctalia")
                  end'')
              ];
            }
          ];

          env =
            lib.mapAttrsToList
              (name: value: {
                _args = [
                  name
                  value
                ];
              })
              {
                XDG_CURRENT_DESKTOP = "Hyprland";
                XDG_SESSION_TYPE = "wayland";
                XDG_SESSION_DESKTOP = "Hyprland";
                NIXOS_OZONE_WL = "1";
              };

          workspace_rule = map (ws: {
            workspace = toString ws;
            persistent = true;
          }) (lib.range 1 5);

          config = {
            input = {
              numlock_by_default = true;
              kb_options = "ctrl:nocaps";
            };
            general = {
              gaps_out = 6;
              gaps_in = 3;
              border_size = 2;
              # Override only Stylix's border colours; keep the rest of its theme.
              "col.active_border" = lib.mkForce "rgb(${stylixColors.base03})";
              "col.inactive_border" = lib.mkForce "rgb(${stylixColors.base02})";
            };
            cursor.no_hardware_cursors = true;
            decoration = {
              rounding = 10;
              blur.enabled = true;
            };
            misc = {
              disable_hyprland_logo = true;
              disable_splash_rendering = true;
              mouse_move_enables_dpms = true;
              key_press_enables_dpms = true;
            };
          };

          animation =
            map
              (
                { leaf, speed }:
                {
                  inherit leaf speed;
                  enabled = true;
                  bezier = "default";
                }
              )
              [
                {
                  leaf = "windows";
                  speed = 4;
                }
                {
                  leaf = "windowsOut";
                  speed = 4;
                }
                {
                  leaf = "border";
                  speed = 2;
                }
                {
                  leaf = "fade";
                  speed = 2;
                }
                {
                  leaf = "fadeDim";
                  speed = 2;
                }
                {
                  leaf = "workspaces";
                  speed = 3;
                }
              ];
        };
      };
    };
}
