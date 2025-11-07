{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.lazygit;
  transparentButtons = mkBoolOpt false "${namespace}.programs.lazygit.trasparentButtons";

  stylixEnabled = config.${namespace}.programs.stylix.enable or false;

  accent = if stylixEnabled then "#${config.lib.stylix.colors.base0D}" else null;
  muted = if stylixEnabled then "#${config.lib.stylix.colors.base03}" else null;
  selected = if stylixEnabled then "#${config.lib.stylix.colors.base02}" else null;
in
{
  options.${namespace}.programs.lazygit = with types; {
    enable = mkBoolOpt false "Enable programs.lazygit";
  };

  config = mkIf cfg.enable {
    programs.lazygit = {
      enable = true;
      settings = lib.mkForce {
        gui = {
          theme = lib.mkIf stylixEnabled ({
            activeBorderColor = [
              accent
              "bold"
            ];
            inactiveBorderColor = [ muted ];
            selectedLineBgColor = [ selected ];
          });
          showListFooter = false;
          showRandomTip = false;
          showCommandLog = false;
          showBottomLine = false;
          nerdFontsVersion = "3";
        };
      };
    };
  };
}
