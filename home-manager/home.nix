{ config, pkgs, lib, ... }:

{
  # TODO please change the username & home directory to your own
  home.username = "mathai";
  home.homeDirectory = "/home/mathai";

  xresources.properties = {
    "Xcursor.size" = lib.mkDefault 16;
    "Xft.dpi" = 192;
  };

  imports = [
    ./packages.nix
    ./modules
  ];

  home.stateVersion = "24.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
