{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.keepassxc;
in
{
  options.${namespace}.programs.keepassxc = with types; {
    enable = mkBoolOpt false "Enable keepassxc";
  };
  config = mkIf cfg.enable {
    programs.keepassxc = {

      enable = true;

      settings = {

        Browser.Enabled = true;

        GUI = {
          ApplicationTheme = "classic";
          CompactMode = false;
          TrayIconAppearance = "monochrome-light";
        };

        PasswordGenerator.Length = 32;
      };
    };
  };
}
