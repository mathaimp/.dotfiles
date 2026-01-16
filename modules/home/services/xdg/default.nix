{
  config,
  lib,
  libEx,
  namespace,
  pkgs,
  ...
}:
with lib;
with libEx.${namespace};
let
  cfg = config.${namespace}.services.xdg;
in
{
  options.${namespace}.services.xdg = with types; {
    enable = mkBoolOpt false "Enable xdg";
  };

  config = mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];

      config = {
        common = {
          default = [ "gtk" ];
        };
        hyprland = {
          default = [ "hyprland" "gtk" ];
        };
      };
    };
  };
}
