{
  flake.homeModules.ghostty =
    { pkgs, ... }:
    {
      preferences.terminal = "ghostty";

      home.sessionVariables = {
        TERMINAL = "ghostty";
      };

      programs.ghostty = {
        enable = true;
        enableZshIntegration = true;
        installBatSyntax = true;
        installVimSyntax = true;
        settings = {
          theme = "Nord";
          font-size = 14;
          window-padding-x = 8;
          window-padding-y = 0;
          window-padding-balance = true;
          window-padding-color = "extend";
          copy-on-select = "clipboard";
          bell-features = "audio";
          bell-audio-volume = 0.4;
          clipboard-read = "deny";
          bell-audio-path = "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/message.oga";
        };
      };
    };
}
