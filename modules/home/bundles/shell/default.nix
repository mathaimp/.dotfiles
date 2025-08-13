{ options
, config
, lib
, pkgs
, namespace
, ...
}:
with lib;
with lib.${namespace};
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
      tldr
      wget
      ncdu
      duf
      appimage-run
      which
      trash-cli
      tealdeer
      ripgrep
      fd

      # archives
      zip
      xz
      unzip
      p7zip-rar

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
