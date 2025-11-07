{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.hardware.networking;
in
{
  options.${namespace}.hardware.networking = with types; {
    enable = mkBoolOpt false "Enable networkmanager";
  };

  config = mkIf cfg.enable {
    networking = {
      networkmanager.enable = true;
    };
    # Enable systemd-resolved for services like tailscale, etc.
    services.resolved = {
      enable = true;
      dnssec = "true";
      domains = [ "~." ];
      fallbackDns = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
      ];
      dnsovertls = "opportunistic";
    };
  };
}
