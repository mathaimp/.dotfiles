{ pkgs, config, ... }:
{
  services.xserver.displayManager.gdm.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal.enable = true;
  #xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  
  environment.systemPackages = with pkgs; [
    polkit_gnome # For auth in wm
    cinnamon.nemo-with-extensions
  ];
}
