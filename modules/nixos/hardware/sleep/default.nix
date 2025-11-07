{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.hardware.sleep;
in
{
  options.${namespace}.hardware.sleep = with types; {
    enable = mkBoolOpt false "Setup power and sleep";
  };

  config = mkIf cfg.enable {
    services = {
      # Enable the ACPI daemon.
      acpid.enable = true;

      # Extra config options for systemd-logind.
      logind.settings.Login = {
        HandlePowerKey = "suspend";
        HandleLidSwitch = "hibernate";
        HandleLidSwitchExternalPower = "suspend";
      };

      # Enable Upower, a DBus service that provides power management support to applications.
      upower = {
        enable = true;
        percentageLow = 10;
        percentageCritical = 5;
        percentageAction = 3;
        criticalPowerAction = "Hibernate";
      };

    };
  };
}
