{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.fail2ban;
in
{
  options.${namespace}.services.fail2ban = with types; {
    enable = mkBoolOpt false "Enable fail2ban";
  };

  config = mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
    };
  };
}
