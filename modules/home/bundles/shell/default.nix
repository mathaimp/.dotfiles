{
  config,
  lib,
  libEx,
  pkgs,
  namespace,
  ...
}:
with lib;
with libEx.${namespace};
let
  cfg = config.${namespace}.bundles.shell;
in
{
  options.${namespace}.bundles.shell = with types; {
    enable = mkBoolOpt false "Whether or not to enable shell configuration.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Terminal
      bottom
      coreutils
      gcc
      killall
      wget
      ncdu
      duf
      which
      trash-cli
      tealdeer
      ripgrep
      fd
      aria2

      # archives
      zip
      xz
      unzip

      # system tools
      sysstat
      lm_sensors # for `sensors` command
      ethtool
      pciutils # lspci
      usbutils # lsusb
      nmap # network scanning
    ];

    olympus = {
      programs = {
        bat = enabled;
        eza = enabled;
        fzf = enabled;
        git = enabled;
        lazygit = enabled;
        neovim = enabled;
        powerlevel10k = enabled;
        tmux = enabled;
        zoxide = enabled;
        zsh = enabled;
      };
    };
  };
}
