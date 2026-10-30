{
  flake.nixosModules.plymouth =
    {
      lib,
      ...
    }:
    {
      boot = {
        # silence first boot output
        consoleLogLevel = 3;
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
