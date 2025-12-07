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
    enable = mkBoolOpt false "Enable the nix helper (nh)";
  };

  config = mkIf cfg.enable {
    programs.nh = {
      enable = true;
    };
  };
}
