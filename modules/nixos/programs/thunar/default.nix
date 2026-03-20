{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.thunar;
in
{
  options.${namespace}.programs.thunar = with types; {
    enable = mkBoolOpt false "Enable Thunar";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      file-roller
    ];

    services = {
      gvfs.enable = true; # Mount, trash, and other functionalities
      tumbler.enable = true; # Thumbnail support for images
    };
    programs = {
      thunar.enable = true;
      xfconf.enable = true; # To save preferances
      thunar.plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };
}
