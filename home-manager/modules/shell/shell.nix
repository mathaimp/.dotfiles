{ pkgs, ... }:
{

  imports = [
    ./neovim.nix
    ./tmux.nix
  ];

  # Packages requiered for zsh
  home.packages = with pkgs; [
    #ZSH utils
    nerdfonts
    zsh-powerlevel10k
    fzf
    zsh-fzf-tab
    eza
    zoxide
    tmux
  ];
  
  # basic configuration of git, please change to your own
  programs.git.enable = true;
  home.file.".gitconfig".source = ./.gitconfig;

  # Zsh Setup
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtraFirst = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ~/.p10k.zsh
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      '';
    initExtra = builtins.readFile ./.zshrc;
  };

  # p10k config
  home.file.".p10k.zsh".source = ./.p10k.zsh;

  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };
}
