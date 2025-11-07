{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.bundles.server;
in
{
  options.${namespace}.bundles.server = with types; {
    enable = mkBoolOpt false "Whether or not to enable server configuration.";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      wget
      curl
      git
      fastfetch
      aria2
    ];

    services = {
      udisks2.enable = true; # Required for e-reader connections to calibre
    };

    olympus = {
      config.nix = enabled;

      hardware = {
        networking = enabled;
      };

      programs = {
        nh = enabled;
        nix-ld = enabled;
      };

      services = {
        security = enabled;
        ssh = {
          enable = true;
          passwordAuth = true;
        };
      };

      system = {
        fonts = enabled;
        locale = enabled;
      };
    };
  };
}
