{ pkgs, ... }:
{
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    #mangohud get from home-manager
    lutris
    wineWowPackages.stable
    transmission_4-gtk
  ];

}
