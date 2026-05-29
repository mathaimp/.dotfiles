{ self, ... }:
{
  flake.nixosModules.hyprland = {
    imports = [
      self.nixosModules.nautilus
      self.nixosModules.sddm
      self.nixosModules.polkit-gnome
    ];
    environment = {
      sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
    };
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
