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
  cfg = config.${namespace}.programs.direnv;
in
{
  options.${namespace}.programs.direnv = with types; {
    enable = mkBoolOpt false "Enable direnv";
  };
  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };
  };
}
