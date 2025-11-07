{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.firefox;
in
{
  options.${namespace}.programs.firefox = {
    enable = mkBoolOpt false "Enable Firefox";
  };

  config = mkIf cfg.enable {

    environment.sessionVariables = {
      BROWSER = "firefox";
    };

    programs.firefox = {
      enable = true;
      package = pkgs.firefox;
    };

  };
}
