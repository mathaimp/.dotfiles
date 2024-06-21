{ config, ... }:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      background = [
        {
          monitor = "";
          path = "${config.stylix.image}";
          blur_passes = 3;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];

      general = [
        {
          no_fade_in = false;
          grace = 0;
          disable_loading_bar = true;
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "250, 60";
          outline_thickness = 2;
          dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
          dots_spacing = 0.2; # Scale of dots' absolute size, 0.0 - 1.0
          dots_center = true;
          #outer_color = rgba(0, 0, 0, 0)
          #inner_color = rgba(0, 0, 0, 0.5)
          #font_color = rgb(200, 200, 200)
          fade_on_empty = false;
          font_family = "JetBrains Mono Nerd Font Mono";
          #placeholder_text = ''<span foreground="##cdd6f4">Input Password...</span>'';
          placeholder_text = ''<span>Input Password...</span>'';
          hide_input = false;
          position = "0, -120";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        {
          monitor = "";
          text = ''cmd[update:1000] date +"%-I:%M%p"'';
          #color = $foreground
          #color = rgba(255, 255, 255, 0.6)
          font_size = 120;
          font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
          position = "0, -300";
          halign = "center";
          valign = "top";
        }
        {
          monitor = "";
          text = "Hi there, $USER";
          #color = $foreground
          #color = rgba(255, 255, 255, 0.6)
          font_size = 25;
          font_family = "JetBrains Mono Nerd Font Mono";
          position = "0, -40";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(playerctl metadata --format '{{title}}  {{artist}}')"'';
          #color = $foreground
          #color = rgba(255, 255, 255, 0.6)
          font_size = 18;
          font_family = "JetBrainsMono, Font Awesome 6 Free Solid";
          position = "0, -20";
          halign = "center";
          valign = "bottom";
        }
      ];
    };
  };
}
