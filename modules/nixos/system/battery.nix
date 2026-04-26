{
  flake.nixosModules.battery =
    {
      config,
      lib,
      ...
    }:
    {

      services = {
        # Better scheduling for CPU cycles - thanks System76!!!
        system76-scheduler.settings.cfsProfiles.enable = true;

        # Enable TLP (better than gnomes internal power manager)
        tlp = {
          enable = true;
          settings = {
            CPU_BOOST_ON_AC = 1;
            CPU_BOOST_ON_BAT = 0;
            CPU_SCALING_GOVERNOR_ON_AC = "performance";
            CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
            CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
            CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          };
        };

        # Disable GNOMEs power management
        power-profiles-daemon.enable = false;
      };

      # Enable powertop
      # powerManagement.powertop.enable = true;
    };
}
