{
  flake.nixosModules.networking = {
    networking = {
      networkmanager.enable = true;
    };
    # Enable systemd-resolved for services like tailscale, etc.
    services.resolved = {
      enable = true;
      settings.Resolve = {
        DNSSEC = "true";
        FallbackDNS = [
          "1.0.0.1"
          "[2606:4700:4700::1001]"
          "1.1.1.1"
          "[2606:4700:4700::1111]"
        ];
        DNSOverTLS = "opportunistic";
      };
    };
  };
}
