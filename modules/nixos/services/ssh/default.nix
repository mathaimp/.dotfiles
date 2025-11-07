{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.ssh;
in
{
  options.${namespace}.services.ssh = with types; {
    enable = mkBoolOpt false "Enable ssh";
    passwordAuth = mkBoolOpt false "Allow ssh using password";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        X11Forwarding = true;
        PermitRootLogin = "no"; # disable root login
        PasswordAuthentication = cfg.passwordAuth; # disable password login
      };
      openFirewall = true;
    };
  };
}
