{ options
, config
, osConfig
, lib
, pkgs
, inputs
, namespace
, ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.hyprlock;
  weatherScript = (pkgs.writeShellScriptBin "weather" (builtins.readFile ./scripts/weather.sh));
  infolockScript = (pkgs.writeShellScriptBin "infolock" (builtins.readFile ./scripts/infolock.sh));
  playerctlockScript = (pkgs.writeShellScriptBin "playerctlock" (builtins.readFile ./scripts/playerctlock.sh));
  stylixEnabled = config.${namespace}.programs.stylix.enable or false;
  stylixColors = if stylixEnabled then osConfig.lib.stylix.colors else null;
in
{
  options.${namespace}.programs.hyprlock = with types; {
    enable = mkBoolOpt false "Enable hyprlock";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bc
      jq
      playerctl
    ] ++ [
      weatherScript
      infolockScript
      playerctlockScript
    ];

    sops.secrets = mkIf (osConfig.${namespace}.programs.sops.enable or false) {
      "weather/api" = {};
    };

    programs.hyprlock = {
      enable = true;
      settings = {
        background = [
          {
            monitor = "";
            path = lib.mkIf stylixEnabled "${osConfig.stylix.image}";
            color = "rgb(${stylixColors.base01-rgb-r}, ${stylixColors.base01-rgb-g}, ${stylixColors.base01-rgb-b})";
            blur_passes = 2;
            contrast = 0.8916;
            brightness = 0.7172;
            vibrancy = 0.1696;
            vibrancy_darkness = 0.0;
          }
        ];

        general = [
          {
            no_fade_in = true;
            grace = 0;
            disable_loading_bar = false;
            hide_cursor = false;
            ignore_empty_input = true;
          }
        ];

        input-field = [
          {
            monitor = "";
            size = "300, 60";
            outline_thickness = 0;
            dots_size = 0.1; # Scale of input-field height, 0.2 - 0.8
            dots_spacing = 0.2; # Scale of dots' absolute size, 0.0 - 1.0
            dots_center = true;
            outer_color = "rgba(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b}, 0.02)";
            inner_color = "rgba(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b}, 0.02)";
            font_color = "rgb(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b})";
            fade_on_empty = false;
            check_color = "rgba(${stylixColors.base01-rgb-r}, ${stylixColors.base01-rgb-g}, ${stylixColors.base01-rgb-b}, 0.2)";
            fail_color = "rgba(${stylixColors.base08-rgb-r}, ${stylixColors.base08-rgb-g}, ${stylixColors.base08-rgb-b}, 0.1)";
            fail_transition = 400;
            #font_family = "JetBrains Mono Nerd Font Mono";
            placeholder_text = ''<span foreground="##cdd6f4">  $USER</span>'';
            fail_text = ''<span foreground="##cdd6f4">$FAIL</span>'';
            hide_input = false;
            position = "0, -470";
            halign = "center";
            valign = "center";
          }
        ];

        label = [
          # Time HR
          {
            monitor = "";
            text = ''cmd[update:100] echo -e "$(date +"%H")"'';
            color = "rgb(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b})";
            shadow_size = 3;
            shadow_color = "rgb(0,0,0)";
            shadow_boost = 1.2;
            font_size = 150;
            font_family = "JetBrains Mono Nerd Font Mono";
            position = "0, -250";
            halign = "center";
            valign = "top";
          }

          # Time
          {
            monitor = "";
            text = ''cmd[update:100] echo -e "$(date +"%M")"'';
            color = "rgb(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b})";
            shadow_size = 3;
            shadow_color = "rgb(0,0,0)";
            shadow_boost = 1.2;
            font_size = 150;
            font_family = "JetBrains Mono Nerd Font Mono";
            position = "0, -420";
            halign = "center";
            valign = "top";
          }

          # Date
          {
            monitor = "";
            text = ''cmd[update:100] echo -e "$(date +"%d %b %A")"'';
            color = "rgb(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b})";
            shadow_size = 3;
            shadow_color = "rgb(0,0,0)";
            shadow_boost = 1.2;
            font_size = 14;
            font_family = "JetBrains Mono Nerd Font Mono";
            position = "0, -130";
            halign = "center";
            valign = "center";
          }

          # PLAYER TITTLE
          {
            monitor = "";
            text = ''cmd[update:100] echo "$(playerctlock --title) $(playerctlock --status)"'';
            color = "rgb(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b})";
            font_size = 16;
            font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
            position = "0, -280";
            halign = "center";
            valign = "center";
          }

          # PLAYER Length
          {
            monitor = "";
            text = ''cmd[update:100] echo "$(playerctlock --length) "'';
            color = "rgb(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b})";
            font_size = 11;
            font_family = "JetBrains Mono Nerd Font Mono";
            position = "-830, -310";
            halign = "right";
            valign = "center";
          }

          # PLAYER SOURCE
          {
            monitor = "";
            text = ''cmd[update:100] echo "$(playerctlock --source)"'';
            color = "rgba(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b}, 0.6)";
            font_size = 10;
            font_family = "JetBrains Mono Nerd Font Mono";
            position = "-830, -330";
            halign = "right";
            valign = "center";
          }

          # PLAYER ALBUM 
          {
            monitor = "";
            text = ''cmd[update:100] echo "$(playerctlock --album)"'';
            color = "rgb(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b})";
            font_size = 10;
            font_family = "JetBrains Mono Nerd Font Mono";
            position = "840, -330";
            halign = "left";
            valign = "center";
          }

          # PLAYER Artist
          {
            monitor = "";
            text = ''cmd[update:100] echo "$(playerctlock --artist)"'';
            color = "rgba(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b}, 0.8)";
            font_size = 10;
            font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
            position = "840, -310";
            halign = "left";
            valign = "center";
          }

          # Weather
          {
            monitor = "";
            text = ''cmd[update:1000] echo "$(weather $(cat ${config.sops.secrets."weather/api".path}))"'';
            color = "rgb(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b})";
            font_size = 10;
            font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
            position = "0, 465";
            halign = "center";
            valign = "center";
          }

          # Information
          {
            monitor = "";
            text = ''cmd[update:10000] echo -e "$(infolock)"'';
            color = "rgb(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b})";
            font_size = 12;
            font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
            position = "-20, -510";
            halign = "right";
            valign = "center";
          }
        ];
      };
    };
  };
}
