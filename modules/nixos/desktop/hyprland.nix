{ self, ... }:
{
  flake.nixosModules.hyprland = {
    imports = [
      self.nixosModules.nautilus
      self.nixosModules.gdm
      self.nixosModules.polkit-gnome
    ];
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    services = {
      gvfs.enable = true;
      devmon.enable = true;
      upower.enable = true;
    };
  };
}
