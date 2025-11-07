{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.ghostty;
in
{
  options.${namespace}.programs.ghostty = with types; {
    enable = mkBoolOpt false "Enable ghostty";
  };
  config = mkIf cfg.enable {

    home.sessionVariables = {
      TERMINAL = "ghostty";
    };

    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      installBatSyntax = true;
      installVimSyntax = true;
      settings = {
        theme = "Rose Pine";
        font-size = 14;
        window-padding-x = 5;
        window-padding-y = 5;
        copy-on-select = "clipboard";
      };
    };
  };
}
