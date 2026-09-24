{
  flake.homeModules.zsh =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.zsh = {
        enable = true;
        dotDir = "${config.xdg.configHome}/zsh";
        envExtra = ''
          setopt no_global_rcs
        ''; # Skips /etc/zshrc & /etc/zprofile (duplicate compinit, dircolors, promptinit); /etc/zshenv (PATH) still loads
        defaultKeymap = "emacs";
        historySubstringSearch = {
          enable = true;
          searchDownKey = [
            "$terminfo[kcud1]"
            "^[[B"
          ];
          searchUpKey = [
            "$terminfo[kcuu1]"
            "^[[A"
          ];
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
        initContent = lib.mkAfter ''
          eval "$(${pkgs.coreutils}/bin/dircolors -b)"
          ${builtins.readFile ./.zshrc}
        '';
      };
    };
}
