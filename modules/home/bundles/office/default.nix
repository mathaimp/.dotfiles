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
  cfg = config.${namespace}.bundles.office;
in
{
  options.${namespace}.bundles.office = with types; {
    enable = mkBoolOpt false "Enable office bundle";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fladder
      evince
      libreoffice
      obsidian
    ];
  };
}
