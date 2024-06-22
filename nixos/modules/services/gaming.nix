{ pkgs, ... }:
{
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    #mangohud get from home-manager
    lutris
    transmission-gtk
    wineWowPackages.stable
  ];

}
