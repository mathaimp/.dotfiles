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

    programs.thunar.enable = true;
    programs.xfconf.enable = true; # To save preferances
    services.gvfs.enable = true; # Mount, trash, and other functionalities
    services.tumbler.enable = true; # Thumbnail support for images
    programs.thunar.plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];

  };
}
