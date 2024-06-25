{ config, ... }:

with config.lib.stylix.colors;
{  
  #programs.rofi.enable = true;

  home.file.".config/rofi/config.rasi".source = ./config.rasi;

  home.file.".config/rofi/launch.rasi".source = ./launch.rasi;
 
  home.file.".config/rofi/power.rasi".source = ./power.rasi;
  
  home.file.".config/rofi/color.rasi".text = ''
    * {
        font: "JetBrains Mono Nerd Font 13";
        background:     #${base00};
        background-alt: #${base01};
        foreground:     #${base05};
        selected:       #${base0D};
        active:         #${base0D};
        urgent:         #${base09};
    }
  '';
}
