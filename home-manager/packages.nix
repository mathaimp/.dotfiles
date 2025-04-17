{ inputs, pkgs, ... }:
{
  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [

    fastfetch
    ncdu
    duf
    appimage-run
    image-roll
    librewolf

    mangohud

    # ESSENTIALS
    gcc
    sops
    # bitwarden
    keepassxc
    xfce.xfce4-power-manager

    # books
    #helvetica-neue-lt-std
    calibre

    # foliate

    # archives
    zip
    xz
    unzip
    p7zip-rar

    # misc
    pavucontrol
    which
    tree
    trash-cli
    vlc

    # nix related
    nurl

    # productivity
    ffmpeg

    # Notes
    obsidian
    zotero

    # robotics
    arduino-cli
    minicom

    # system tools
    bottom
    nvtopPackages.full
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    nmap # network scanning
    xorg.xhost # mainly for docker really...
  ];
}
