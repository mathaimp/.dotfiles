{ inputs, pkgs, ... }:
{
  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    
    # Browser
    inputs.zen-browser.packages."${system}".default

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
    zotero
    
    # robotics
    qgroundcontrol

    # system tools
    bottom
    nvtopPackages.full
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
  ];
}
