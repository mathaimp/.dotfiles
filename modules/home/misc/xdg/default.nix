{ config
, lib
, namespace
, ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.misc.xdg;
in
{
  options.${namespace}.misc.xdg = {
    enable = mkBoolOpt false "${namespace}.misc.xdg.enable";
  };

  config = mkIf cfg.enable {
    xdg = {
      enable = true;
      userDirs.enable = true;
      desktopEntries."nvim" = {
        name = "Neovim";
        comment = "Edit text files";
        exec = "kitty -e nvim %F";
        icon = "nvim";
        terminal = false;
        type = "Application";
        categories = [ "Utility" "TextEditor" ];
      };
    };
  };
}
