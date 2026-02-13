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
  cfg = config.${namespace}.programs.wine;
in
{
  options.${namespace}.programs.wine = with types; {
    enable = mkBoolOpt false "Enable Wine and Gaming pkgs";
  };

  config = mkIf cfg.enable {
    programs.gamemode.enable = true;
    services.ratbagd.enable = true;
    environment.systemPackages = with pkgs; [
      lutris
      piper
    ];

  };
}
