{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.kitty;
in
{
  options.${namespace}.programs.kitty = with types; {
    enable = mkBoolOpt false "Enable kitty";
  };
  config = mkIf cfg.enable {

    home.sessionVariables = {
      TERMINAL = "kitty";
    };

    programs.kitty = {
      enable = true;
      themeFile = "rose-pine";
      font.size = lib.mkForce 14;
      font.name = lib.mkForce "JetBrainsMono Nerd Font";
      shellIntegration.enableZshIntegration = true;
      settings = {
        enable_audio_bell = false;
        window_padding_width = 5;
        copy_on_select = true;
        clipboard_control = "write-clipboard read-clipboard write-primary read-primary";
        active_border_color = "None";
        term = "xterm-256color";
      };
    };
  };
}
