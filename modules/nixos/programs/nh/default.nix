{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.nh;
in
{
  options.${namespace}.programs.nh = {
    enable = mkBoolOpt false "${namespace}.programs.nh.enable";
  };

  config = mkIf cfg.enable {
    programs.nh = {
      enable = true;
    };
  };
}
