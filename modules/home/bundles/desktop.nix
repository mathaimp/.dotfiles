{ self, ... }:
{
  flake.homeModules.desktop-bundle = {
    imports = [
      self.homeModules.preferences
      self.homeModules.clipse
      self.homeModules.swayosd
      self.homeModules.xdg
    ];
  };
}
