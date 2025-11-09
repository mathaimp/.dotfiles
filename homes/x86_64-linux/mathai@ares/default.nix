{
  lib,
  osConfig,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
{
  snowfallorg.user.enable = true;
  olympus = {
    bundles = {
      common = enabled;
      desktop.hyprland = enabled;
      development = enabled;
      office = enabled;
      shell = enabled;
    };
    programs = {
      firefox = enabled;
      keepassxc = enabled;
      mangohud = enabled;
      spotify = enabled;
      yazi = enabled;
      zathura = enabled;
    };
    services = {
      ludusavi = enabled;
      kdeconnect = enabled;
      rclone = enabled;
      syncthing = enabled;
    };
  };

  # DO NOT MODIFY VALUE
  home.stateVersion = lib.mkDefault (osConfig.system.stateVersion or "24.05");
}
