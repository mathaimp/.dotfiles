{ lib, pkgs, config, ... }:
{
  services.displayManager.gdm.enable = true;

  services.desktopManager.gnome.enable = false;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  # security.pam.services.hyprlock.text = lib.readFile "${pkgs.hyprlock}/etc/pam.d/hyprlock";
  security.pam.services.hyprlock = {};

  environment.systemPackages = with pkgs; [
    polkit_gnome # For auth in wm
    file-roller
  ];

  # File Manager Setup
  programs.thunar.enable = true;
  programs.xfconf.enable = true; # To save preferances
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];

}
