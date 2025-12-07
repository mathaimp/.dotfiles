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
  cfg = config.${namespace}.programs.nix-ld;
in
{
  options.${namespace}.programs.nix-ld = {
    enable = mkBoolOpt false "Enable nix-ld";
  };

  config = mkIf cfg.enable {
    programs.nix-ld = {
      enable = true;
      package = pkgs.nix-ld;
    };
  };
}
