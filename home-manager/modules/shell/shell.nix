{ pkgs, lib, inputs, ... }:
{

  imports = [
    ./neovim.nix
    ./tmux.nix
  ];

  # Packages requiered for zsh
  home.packages = with pkgs; [
    #ZSH utils
    zsh-powerlevel10k
    fzf
    # zsh-fzf-tab
    eza
    zoxide
    tmux
    devenv
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
    '';
    initExtra = builtins.readFile ./.zshrc;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true; # see note on other shells below
    nix-direnv.enable = true;
  };

  # p10k config
  home.file.".p10k.zsh".source = ./.p10k.zsh;

  # Terminal Config
  home.file.".config/ghostty/config".source = ./ghostty.config;

  # Backup Terminal
  # programs.kitty = {
  #   enable = true;
  #   font.size = lib.mkForce 14;
  #   font.name = lib.mkForce "JetBrainsMono Nerd Font";
  #   shellIntegration.enableZshIntegration = true;
  # };

}
