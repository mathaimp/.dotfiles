{ self, ... }:
{
  flake.nixosModules.niri = {
    imports = [
      self.nixosModules.nautilus
      self.nixosModules.gdm
      self.nixosModules.polkit-gnome
    ];
    programs.niri = {
      enable = true;
    };

    services = {
      gvfs.enable = true;
      devmon.enable = true;
      upower.enable = true;
    };
  };
}
