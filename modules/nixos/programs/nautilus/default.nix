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
  cfg = config.${namespace}.programs.nautilus;
in
{
  options.${namespace}.programs.nautilus = with types; {
    enable = mkBoolOpt false "Enable Nautilus";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nautilus
    ];

    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "kitty"; # TODO
    };
  };
}
