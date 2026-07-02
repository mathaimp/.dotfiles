{ self, ... }:
{
  flake.homeModules.mathai-ares = {
    imports = [
      self.homeModules.common-bundle
      self.homeModules.desktop-bundle
      self.homeModules.development-bundle
      self.homeModules.office-bundle
      self.homeModules.shell-bundle

      self.homeModules.hyprland
      self.homeModules.hyprlock
      self.homeModules.hypridle
      # self.homeModules.niri

      self.homeModules.firefox
      self.homeModules.spotify
      self.homeModules.yazi

      self.homeModules.rclone
    ];
    home.stateVersion = "24.05";
  };
}
