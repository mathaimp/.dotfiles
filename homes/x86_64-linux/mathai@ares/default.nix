{
  lib,
  libEx,
  osConfig,
  namespace,
  ...
}:
with lib;
with libEx.${namespace};
{

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
      mangohud = enabled;
      spotify = enabled;
      yazi = enabled;
    };
    services = {
      ludusavi = enabled;
      rclone = enabled;
    };
  };

  # DO NOT MODIFY VALUE
  home.stateVersion = lib.mkDefault (osConfig.system.stateVersion or "24.05");
}
