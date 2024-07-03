{ lib, pkgs, config, ... }:
{
  services.xserver.displayManager.gdm.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal.enable = true;
  #xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.hyprlock.text = lib.readFile "${pkgs.hyprlock}/etc/pam.d/hyprlock";
  
  environment.systemPackages = with pkgs; [
    polkit_gnome # For auth in wm
    cinnamon.nemo-with-extensions
  ];
}
