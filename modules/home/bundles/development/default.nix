{ options
, config
, lib
, pkgs
, namespace
, ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.bundles.development;
in
{
  options.${namespace}.bundles.development = with types; {
    enable = mkBoolOpt false "Whether or not to enable development.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      caligula
      nvitop

      # python
      uv

      # Notes
      obsidian
      zotero

      # robotics
      arduino-cli
      minicom
    ];

    olympus = {
      programs = {
        direnv = enabled;
      };
    };
  };
}
