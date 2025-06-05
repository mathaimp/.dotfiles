{ pkgs, ... }:
{
  programs.gamemode.enable = true;
  services.ratbagd.enable = true;
  environment.systemPackages = with pkgs; [
    #mangohud get from home-manager
    lutris
    piper
    wineWowPackages.stable
    transmission_4-gtk
  ];

}
