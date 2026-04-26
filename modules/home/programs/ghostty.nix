{
  flake.homeModules.ghostty = {
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
        window-padding-x = 10;
        window-padding-y = 10;
        copy-on-select = "clipboard";
      };
    };
  };
}
