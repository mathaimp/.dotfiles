{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.zsh;
in
{
  options.${namespace}.programs.zsh = {
    enable = mkBoolOpt false "${namespace}.programs.zsh.enable";
  };

  config = mkIf cfg.enable {

    programs.zsh = {
      enable = true;
      defaultKeymap = "viins";
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
        clean = "nh clean all";
        rm = "trash";
      };
      initContent = lib.mkBefore ''
        ${builtins.readFile ./.zshrc}
      '';
    };
  };
}
