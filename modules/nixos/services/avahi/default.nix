{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.avahi;
in
{
  options.${namespace}.services.avahi = with types; {
    enable = mkBoolOpt false "Whether or not to configure avahi support.";
  };

  config = mkIf cfg.enable {
    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
        wideArea = true;
        publish = {
          enable = true;
          addresses = true;
          domain = true;
          hinfo = true;
          workstation = true;
          userServices = true;
        };
      };
    };
  };
}
