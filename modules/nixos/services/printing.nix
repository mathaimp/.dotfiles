{
  flake.nixosModules.printing = {
    services = {
      avahi = {
        # Needed to find wireless printer
        enable = true;

        nssmdns4 = true;
        settings.publish = {
          # Needed for detecting the scanner
          disable-publishing = false;

          disable-user-service-publishing = false;
          publish-addresses = true;
        };
      };
      printing = {
        enable = true;
      };
    };
  };
}
