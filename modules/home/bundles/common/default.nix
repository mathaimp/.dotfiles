{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
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
      keepassxc

      # Video/Audio
      vlc
      loupe
      pavucontrol
    ];

    olympus = {
      misc = {
        xdg = enabled;
      };
      programs = {
        kitty = enabled;
        sops = enabled;
        stylix = enabled;
      };
      services = {
        ssh = enabled;
      };
    };
  };
}
