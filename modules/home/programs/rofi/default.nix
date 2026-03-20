{
  config,
  osConfig,
  lib,
  libEx,
  pkgs,
  namespace,
  ...
}:
with lib;
with libEx.${namespace};
let
  cfg = config.${namespace}.programs.rofi;
  stylixEnabled = config.${namespace}.programs.stylix.enable or false;
  stylixColors = if stylixEnabled then osConfig.lib.stylix.colors else null;
  stylixFonts = if stylixEnabled then osConfig.stylix.fonts else null;
in
{
  options.${namespace}.programs.rofi = with types; {
    enable = mkBoolOpt false "Enable rofi";
  };
  config = mkIf cfg.enable {

    home = {
      packages = [ pkgs.rofi ];

      file = {

        ".config/rofi/config.rasi".source = ./config/config.rasi;

        ".config/rofi/launch.rasi".source = ./config/launch.rasi;

        ".config/rofi/power.rasi".source = ./config/power.rasi;

        ".config/rofi/color.rasi".text = ''
          * {
              font: "${stylixFonts.monospace.name} 13";
              background:     #${stylixColors.base00};
              background-alt: #${stylixColors.base01};
              foreground:     #${stylixColors.base05};
              selected:       #${stylixColors.base03};
              active:         #${stylixColors.base0D};
              urgent:         #${stylixColors.base09};
          }
        '';
      };

    };
  };
}
