{ config, pkgs, ... }:
{
  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    
    fastfetch
    ncdu
    duf

    mangohud

    # ESSENTIALS
    gcc

    # archives
    zip
    xz
    unzip
    p7zip

    # networking tools

    # misc
    pavucontrol
    which
    tree
    trash-cli

    # nix related
    nix-prefetch-git

    # productivity
    ffmpeg
    gh

    # system call monitoring
    

    # system tools
    bottom
    nvtop
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
  ];
}
