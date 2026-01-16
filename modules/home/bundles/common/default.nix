{
  config,
  lib,
  libEx,
  pkgs,
  namespace,
  ...
}:
with lib;
with libEx.${namespace};
let
  cfg = config.${namespace}.bundles.common;
in
{
  options.${namespace}.bundles.common = with types; {
    enable = mkBoolOpt false "Whether or not to enable common bundle configuration.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [

      openvpn

      # Video/Audio
      vlc
      loupe
      pavucontrol
    ];

    olympus = {
      misc = {
        desktopEntries = enabled;
      };
      programs = {
        kitty = enabled;
        sops = enabled;
        stylix = enabled;
        zed = enabled;
      };
      services = {
        ssh = enabled;
      };
    };
  };
}
