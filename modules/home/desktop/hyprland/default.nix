{
  flake.homeModules.hyprland =
    {
      config,
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
          # The clipse popup (Mod+V runs the terminal with this class).
          window_rule = lib.optional config.services.clipse.enable {
            name = "clipse";
            match.class = "com.save.clipse";
            float = true;
            size = "622 652";
            stay_focused = true;
          };

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

          # Material 3 motion. Springs are critically damped (damping = 2 * sqrt(stiffness)).
          # Spatial springs move and resize things; effects springs handle colour and opacity.
          curve =
            let
              # Multiplies every spring's speed: stiffness by scale^2 and damping by scale keeps them
              # critically damped. 1 = the M3 reference values.
              springScale = 1.5;
              spring = name: stiffness: dampening: {
                _args = [
                  name
                  {
                    type = "spring";
                    mass = 1;
                    stiffness = stiffness * springScale * springScale;
                    dampening = dampening * springScale;
                  }
                ];
              };
              bezier = name: p1: p2: {
                _args = [
                  name
                  {
                    type = "bezier";
                    points = [
                      p1
                      p2
                    ];
                  }
                ];
              };
            in
            [
              (spring "md3_spatial_fast" 600 49)
              (spring "md3_spatial_default" 300 35)
              (spring "md3_spatial_slow" 160 25)

              (spring "md3_effects_fast" 3800 123)
              (spring "md3_effects_default" 1600 80)
              (spring "md3_effects_slow" 800 57)

              (bezier "md3_standard" [ 0.2 0.0 ] [ 0.0 1.0 ])
              (bezier "md3_emphasized_accel" [ 0.3 0.0 ] [ 0.8 0.15 ])
            ];

          # Multiplies every animation speed below; lower is faster (1 = the values from the M3 reference).
          animation =
            let
              speedScale = 0.3;
              spatial = "md3_spatial_default";
              effects = "md3_effects_default";
            in
            map (a: if a ? speed then a // { speed = a.speed * speedScale; } else a) [
              {
                leaf = "windows";
                enabled = true;
                speed = 5;
                spring = spatial;
              }
              {
                leaf = "windowsIn";
                enabled = true;
                speed = 5;
                spring = spatial;
                style = "popin 92%";
              }
              {
                leaf = "windowsOut";
                enabled = true;
                speed = 2;
                spring = spatial;
                style = "popin 92%";
              }
              {
                leaf = "windowsMove";
                enabled = true;
                speed = 5;
                spring = spatial;
              }

              {
                leaf = "layers";
                enabled = true;
                speed = 3;
                bezier = "md3_standard";
                style = "slide";
              }
              {
                leaf = "layersIn";
                enabled = true;
                speed = 3;
                bezier = "md3_standard";
                style = "slide";
              }
              {
                leaf = "layersOut";
                enabled = true;
                speed = 2.5;
                bezier = "md3_emphasized_accel";
                style = "slide";
              }

              {
                leaf = "fade";
                enabled = true;
                speed = 2;
                spring = effects;
              }
              {
                leaf = "fadeOut";
                enabled = true;
                speed = 2;
                spring = spatial;
              }
              {
                leaf = "fadeDim";
                enabled = true;
                speed = 2;
                spring = effects;
              }
              {
                leaf = "border";
                enabled = true;
                speed = 2;
                spring = effects;
              }
              {
                leaf = "borderangle";
                enabled = false;
              }

              {
                leaf = "workspaces";
                enabled = true;
                speed = 5;
                spring = spatial;
                style = "slide";
              }
              {
                leaf = "specialWorkspace";
                enabled = true;
                speed = 3.5;
                spring = "md3_spatial_fast";
                style = "slidevert";
              }
            ];
        };
      };
    };
}
