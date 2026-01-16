{
  config,
  lib,
  libEx,
  namespace,
  ...
}:
with lib;
with libEx.${namespace};
let
  cfg = config.${namespace}.misc.desktopEntries;
  terminalChoice =
    if config.${namespace}.programs.kitty.enable then
      "kitty"
    else if config.${namespace}.programs.ghostty.enable then
      "ghostty"
    else
      "xterm"; # fallback
in
{
  options.${namespace}.misc.desktopEntries = {
    enable = mkBoolOpt false "${namespace}.misc.desktopEntries.enable";
  };

  config = mkIf cfg.enable {
    xdg = {
      enable = true;
      userDirs.enable = true;
      desktopEntries."nvim" = {
        name = "Neovim";
        comment = "Edit text files";
        exec = "${terminalChoice} -e nvim %F";
        icon = "nvim";
        terminal = false;
        type = "Application";
        categories = [
          "Utility"
          "TextEditor"
        ];
      };
    };
  };
}
