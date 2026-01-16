{
  config,
  lib,
  libEx,
  pkgs,
  namespace,
  ...
}:
with lib;
with libEx.${namespace};
let
  cfg = config.${namespace}.bundles.desktop.hyprland;
in
{
  options.${namespace}.bundles.desktop.hyprland = with types; {
    enable = mkBoolOpt false "Whether or not to enable common bundle configuration.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      brightnessctl
      sway-contrib.grimshot
    ];

    olympus = {
      desktop = {
        hyprland = enabled;
      };
      programs = {
        hyprlock = enabled;
        rofi = enabled;
        swaync = enabled;
        waybar = enabled;
      };
      services = {
        hypridle = enabled;
        xdg = enabled;
      };
    };
  };
}
