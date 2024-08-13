{ pkgs, ... }:
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

    # Notes
    obsidian

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
