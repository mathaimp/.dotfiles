{
  flake.homeModules.zsh =
    { config
    , lib
    , ...
    }:
    {
      programs.zsh = {
        enable = true;
        dotDir = "${config.xdg.configHome}/zsh";
        historySubstringSearch = {
          enable = true;
          searchDownKey = [ "$terminfo[kcud1]" ];
          searchUpKey = [ "$terminfo[kcuu1]" ];
        };
        history = {
          size = 100000;
          save = 100000;
          path = "$HOME/.zsh_history";
          append = true;
          share = true;
          ignoreSpace = true;
          ignoreAllDups = true;
          saveNoDups = true;
          ignoreDups = true;
          findNoDups = true;
        };
        setOptions = [ "NO_BEEP" ];
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        shellAliases = {
          ls = "eza";
          cat = "bat";
          man = "batman";
          c = "clear";
          e = "exit";
          update = "nix flake update --flake ~/.dotfiles";
          rebuild = "nh os switch ~/.dotfiles/";
          clean = "nh clean all -k 5";
          rm = "trash";
        };
        initContent = lib.mkBefore ''
          ${builtins.readFile ./.zshrc}
        '';
      };
    };
}
