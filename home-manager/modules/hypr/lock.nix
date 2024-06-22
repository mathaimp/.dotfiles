{ config, ... }:

with config.lib.stylix.colors;
{
  programs.hyprlock = {
    enable = true;
    settings = {
      background = [
        {
          monitor = "";
          path = "${config.stylix.image}";
          blur_passes = 2;
          contrast = 0.8916;
          brightness = 0.7172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];

      general = [
        {
          no_fade_in = false;
          grace = 1;
          disable_loading_bar = false;
          hide_cursor = false;
          ignore_empty_input = true;
          text_trim = true;
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
          outer_color = "rgb(${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b})";
          inner_color = "rgb(${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b})";
          font_color = "rgb(${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b})";
          fade_on_empty = false;
          check_color = "rgb(${base01-rgb-r}, ${base01-rgb-g}, ${base01-rgb-b})";
          fail_color = "rgb(${base01-rgb-r}, ${base01-rgb-g}, ${base01-rgb-b})";
          fail_transition = 400;
          font_family = "JetBrains Mono Nerd Font Mono";
          placeholder_text = ''<span foreground="##cdd6f4">  $USER</span>'';
          fail_text = ''<span foreground="##cdd6f4">$FAIL</span>'';
          hide_input = false;
          position = "0, -470";
          halign = "center";
          valign = "center";
          zindex = 10;
        }
      ];

      label = [
        # Time HR
        {
          monitor = "";
          text = ''cmd[update:1000] echo -e "$(date +"%H")"'';
          color = "rgb(${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b})";
          shadow_pass = 2;
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
          text = ''cmd[update:1000] echo -e "$(date +"%M")"'';
          color = "rgb(${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b})";
          shadow_pass = 2;
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
          text = ''cmd[update:1000] echo -e "$(date +"%d %b %A")"'';
          color = "rgb(${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b})";
          shadow_pass = 2;
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
          #    text = cmd[update:1000] echo "$(playerctl metadata --format "{{ xesam:title }}" 2>/dev/null | cut -c1-25)"
          text = ''cmd[update:1000] echo "$(${builtins.toString ./.}/playerctlock.sh --title) $(${builtins.toString ./.}/playerctlock.sh --status)"'';
          color = "rgb(${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b})";
          font_size = 16;
          font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
          position = "0, -280";
          halign = "center";
          valign = "center";
        }

        # PLAYER Length
        {
          monitor = "";
          #    text= cmd[update:1000] echo "$(( $(playerctl metadata --format "{{ mpris:length }}" 2>/dev/null) / 60000000 ))m"
          text = ''cmd[update:1000] echo "$(${builtins.toString ./.}/playerctlock.sh --length) "'';
          color = "rgb(${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b})";
          font_size = 11;
          font_family = "JetBrains Mono Nerd Font Mono";
          position = "-830, -310";
          halign = "right";
          valign = "center";
        }

        # PLAYER SOURCE
        {
          monitor = "";
          #    text= cmd[update:1000] echo "$(playerctl metadata --format "{{ mpris:trackid }}" 2>/dev/null | grep -Eo "chromium|firefox|spotify")"
          text = ''cmd[update:1000] echo "$(${builtins.toString ./.}/playerctlock.sh --source)"'';
          color = "rgba(${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b}, 0.6)";
          font_size = 10;
          font_family = "JetBrains Mono Nerd Font Mono"; 
          position = "-840, -330";
          halign = "right";
          valign = "center";
        }

        # PLAYER ALBUM 
        {
          monitor = "";
          #    text= cmd[update:1000] echo "$(~/.config/hypr/bin/album.sh)"
          text = ''cmd[update:1000] echo "$(${builtins.toString ./.}/playerctlock.sh --album)"'';
          color = "rgb(${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b})";
          font_size = 10;
          font_family = "JetBrains Mono Nerd Font Mono";
          position = "840, -330";
          halign = "left";
          valign = "center";
        }

        # PLAYER Artist
        {
          monitor = "";
          #    text = cmd[update:1000] echo "$(playerctl metadata --format "{{ xesam:artist }}" 2>/dev/null | cut -c1-30)"
          text = ''cmd[update:1000] echo "$(${builtins.toString ./.}/playerctlock.sh --artist)"'';
          color = "rgba(${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b}, 0.8)";
          font_size = 10;
          font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
          position = "840, -310";
          halign = "left";
          valign = "center";
        }
        
        # Weather
        {
          monitor = "";
          text = ''cmd[update:60000] echo "$(${builtins.toString ./.}/weather.sh)"'';
          color = "rgb(${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b})";
          font_size = 10;
          font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
          position = "0, 465";
          halign = "center";
          valign = "center";
        }

        # Information
        {
          monitor = "";
          text = ''cmd[update:1000] echo -e "$(${builtins.toString ./.}/infonlock.sh)"'';
          color = "rgb(${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b})";
          font_size = 12;
          font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
          position = "-20, -510";
          halign = "right";
          valign = "center";
        }
      ];
    };
  };
}
