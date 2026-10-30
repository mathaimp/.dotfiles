{ self, ... }:
{
  flake.homeModules.desktop-bundle = {
    imports = [
      self.homeModules.swayosd
      self.homeModules.xdg
    ];
  };
}
