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
  cfg = config.${namespace}.programs.plymouth;
in
{
  options.${namespace}.programs.plymouth = {
    enable = mkBoolOpt false "Enable Plymouth";
  };

  config = mkIf cfg.enable {
    boot = {
      # silence first boot output
      consoleLogLevel = 3;
      initrd.verbose = false;
      initrd.systemd.enable = true;
      kernelParams = [
        "quiet"
        "splash"
        "intremap=on"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];

      # Dont show systemd boot unless a key is pressed
      loader.timeout = 0;

      # plymouth, showing after LUKS unlock
      plymouth = {
        enable = true;
        theme = lib.mkForce "bgrt";
      };
    };
  };
}
