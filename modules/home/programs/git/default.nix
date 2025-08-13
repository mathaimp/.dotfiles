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
  cfg = config.${namespace}.programs.git;
in
{
  options.${namespace}.programs.git = with types; {
    enable = mkBoolOpt false "Enable git";
  };
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      delta.enable = true;
      lfs.enable = true;
    };
    home.file.".gitconfig".source = ./.gitconfig;
  };
}
