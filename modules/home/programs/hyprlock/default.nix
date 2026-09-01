{
  flake.homeModules.hyprlock =
    {
      config,
      osConfig,
      pkgs,
      ...
    }:
    let
      weatherScript = pkgs.writeShellScriptBin "weather" (builtins.readFile ./scripts/weather.sh);
      infolockScript = pkgs.writeShellScriptBin "infolock" (builtins.readFile ./scripts/infolock.sh);
      playerctlockScript = pkgs.writeShellScriptBin "playerctlock" (
        builtins.readFile ./scripts/playerctlock.sh
      );
      stylixColors = osConfig.lib.stylix.colors;
      stylixFonts = osConfig.stylix.fonts;
    in
    {
      home.packages =
        with pkgs;
        [
          bc
          jq
          playerctl
        ]
        ++ [
          weatherScript
          infolockScript
          playerctlockScript
        ];

      sops.secrets = {
        "weather/api" = { };
      };

      programs.hyprlock = {
        enable = true;
        settings = {
          background = [
            {
              monitor = "";
              path = "${osConfig.stylix.image}";
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
              size = "15.625%, 5.5%";
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
              position = "0%, -43.5%";
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
              font_family = "${stylixFonts.sansSerif.name}";
              position = "0%, -23%";
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
              font_family = "${stylixFonts.sansSerif.name}";
              position = "0%, -39%";
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
              font_family = "${stylixFonts.sansSerif.name}";
              position = "0%, -12%";
              halign = "center";
              valign = "center";
            }

            # PLAYER TITTLE
            {
              monitor = "";
              text = ''cmd[update:100] echo "$(playerctlock --title) $(playerctlock --status)"'';
              color = "rgb(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b})";
              font_size = 16;
              font_family = "${stylixFonts.sansSerif.name} ExtraBold";
              position = "0%, -26%";
              halign = "center";
              valign = "center";
            }

            # PLAYER Length
            {
              monitor = "";
              text = ''cmd[update:100] echo "$(playerctlock --length) "'';
              color = "rgb(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b})";
              font_size = 11;
              font_family = "${stylixFonts.sansSerif.name}";
              position = "-43.25%, -28.75%";
              halign = "right";
              valign = "center";
            }

            # PLAYER SOURCE
            {
              monitor = "";
              text = ''cmd[update:100] echo "$(playerctlock --source)"'';
              color = "rgba(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b}, 0.6)";
              font_size = 10;
              font_family = "${stylixFonts.sansSerif.name}";
              position = "-43.25%, -30.5%";
              halign = "right";
              valign = "center";
            }

            # PLAYER ALBUM
            {
              monitor = "";
              text = ''cmd[update:100] echo "$(playerctlock --album)"'';
              color = "rgb(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b})";
              font_size = 10;
              font_family = "${stylixFonts.sansSerif.name}";
              position = "43.75%, -30.5%";
              halign = "left";
              valign = "center";
            }

            # PLAYER Artist
            {
              monitor = "";
              text = ''cmd[update:100] echo "$(playerctlock --artist)"'';
              color = "rgba(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b}, 0.8)";
              font_size = 10;
              font_family = "${stylixFonts.sansSerif.name} ExtraBold";
              position = "43.75%, -28.75%";
              halign = "left";
              valign = "center";
            }

            # Weather
            {
              monitor = "";
              text = ''cmd[update:1000] echo "$(weather $(cat ${config.sops.secrets."weather/api".path}))"'';
              color = "rgb(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b})";
              font_size = 10;
              font_family = "${stylixFonts.sansSerif.name} ExtraBold";
              position = "0%, 43%";
              halign = "center";
              valign = "center";
            }

            # Information
            {
              monitor = "";
              text = ''cmd[update:10000] echo -e "$(infolock)"'';
              color = "rgb(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b})";
              font_size = 12;
              font_family = "${stylixFonts.sansSerif.name} ExtraBold";
              position = "-1%, -47.25%";
              halign = "right";
              valign = "center";
            }
          ];
        };
      };
    };
}
