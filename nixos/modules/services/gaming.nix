{ pkgs, ... }:
{
  programs.gamemode.enable = true;
  
  environment.systemPackages = with pkgs; [
    mangohud
    lutris
    transmission-gtk
    wineWowPackages.stable
  ];

}
