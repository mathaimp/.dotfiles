{config, ... }:
{
  home.file.".config/waybar/config".source = ./config.jsonc;

  home.file.".config/waybar/style.css".source = ./style.css;
}
