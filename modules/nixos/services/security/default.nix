{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.security;
in
{
  options.${namespace}.services.security = with types; {
    enable = mkBoolOpt false "Enable security";
  };

  config = mkIf cfg.enable {
    # Enable security levels for Thunderbolt 3 on GNU/Linux.
    services.hardware.bolt.enable = true;

    networking.firewall.enable = true;

    security = {
      rtkit.enable = true;
    };
  };
}
