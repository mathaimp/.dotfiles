{ options
, config
, lib
, pkgs
, inputs
, namespace
, ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.bat;
in
{
  options.${namespace}.programs.bat = with types; {
    enable = mkBoolOpt false "Enable bat";
  };
  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [ batman ];
    };
  };
}
