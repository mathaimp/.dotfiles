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
  cfg = config.${namespace}.programs.rofi;
  stylixEnabled = config.${namespace}.programs.stylix.enable or false;
  stylixColors = if stylixEnabled then osConfig.lib.stylix.colors else null;
in
{
  options.${namespace}.programs.rofi = with types; {
    enable = mkBoolOpt false "Enable rofi";
  };
  config = mkIf cfg.enable {

    home.packages = [ pkgs.rofi ];

    home.file.".config/rofi/config.rasi".source = ./config/config.rasi;

    home.file.".config/rofi/launch.rasi".source = ./config/launch.rasi;

    home.file.".config/rofi/power.rasi".source = ./config/power.rasi;

    home.file.".config/rofi/color.rasi".text = ''
      * {
          font: "JetBrains Mono Nerd Font 13";
          background:     #${stylixColors.base00};
          background-alt: #${stylixColors.base01};
          foreground:     #${stylixColors.base05};
          selected:       #${stylixColors.base03};
          active:         #${stylixColors.base0D};
          urgent:         #${stylixColors.base09};
      }
    '';

  };
}
