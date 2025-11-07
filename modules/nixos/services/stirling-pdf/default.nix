{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.stirling-pdf;
in
{
  options.${namespace}.services.stirling-pdf = with types; {
    enable = mkBoolOpt false "Enable stirling-pdf";
  };

  config = mkIf cfg.enable {
    services.stirling-pdf = {
      enable = true;
      environment = {
        SERVER_PORT = 3000;
      };
    };
    networking.firewall = {
      allowedTCPPorts = [ 3000 ];
    };
  };
}
