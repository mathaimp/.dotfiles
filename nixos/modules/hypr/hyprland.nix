{ lib, pkgs, ... }:
{

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = (with pkgs; [
    gnome-tour
    nautilus
    gnome-terminal
    epiphany
    geary
  ]) ++ (with pkgs.gnome; [
    gnome-music
    gnome-characters
  ]);

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  security.pam.services.hyprlock.text = lib.readFile "${pkgs.hyprlock}/etc/pam.d/hyprlock";

  environment.systemPackages = with pkgs; [
    polkit_gnome # For auth in wm
    cinnamon.nemo-with-extensions
  ];
}
