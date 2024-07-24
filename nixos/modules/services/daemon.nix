{config, ... }:
{
  services = {
    # Enable the ACPI daemon.
    acpid.enable = true;

    # Enable the auto-cpufreq daemon.
    power-profiles-daemon.enable = false;
    auto-cpufreq.enable = true;

    # Enable security levels for Thunderbolt 3 on GNU/Linux.
    hardware.bolt.enable = true;

    # Extra config options for systemd-logind.
    logind = {
      powerKey = "poweroff";
      lidSwitch = "hibernate";
      lidSwitchExternalPower = "suspend";
    };

    # Enable thermald, the temperature management daemon.
    #thermald.enable = true; # Disabled on amd

    # Enable Upower, a DBus service that provides power management support to applications.
    upower = {
      enable = true;
      percentageLow = 30;
      percentageCritical = 10;
      percentageAction = 5;
      criticalPowerAction = "HybridSleep";
    };
  };
}
