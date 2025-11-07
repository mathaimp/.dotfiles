{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.hardware.btrfs;
in
{
  options.${namespace}.hardware.btrfs = with types; {
    enable = mkBoolOpt false "Enable btrfs settings";
  };

  config = mkIf cfg.enable {

    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };
  };
}
