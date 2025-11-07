{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.system.boot.systemd-boot;
in
{
  options.${namespace}.system.boot.systemd-boot = with types; {
    enable = mkBoolOpt false "Whether or not to enable systemd-booting.";
    wait-for-network = mkBoolOpt false "Wait for network on servers";
  };

  config = mkIf cfg.enable {
    boot.initrd.systemd.network.wait-online.enable = cfg.wait-for-network;
    boot.loader = {
      systemd-boot = {
        enable = true;
        editor = false;
      };
      efi.canTouchEfiVariables = true;

      timeout = 5;
    };
  };
}
