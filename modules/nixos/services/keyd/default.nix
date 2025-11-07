{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.keyd;
in
{
  options.${namespace}.services.keyd = with types; {
    enable = mkBoolOpt false "Enable keyd binds";
  };

  config = mkIf cfg.enable {
    services.keyd = {
      enable = true;
      keyboards = {
        # The name is just the name of the configuration file, it does not really matter
        default = {
          ids = [ "*" ]; # what goes into the [id] section, here we select all keyboards
          # Everything but the ID section:
          settings = {
            # The main layer, if you choose to declare it in Nix
            main = {
              capslock = "overload(control, esc)";
            };
          };
          extraConfig = ''
            # put here any extra-config, e.g. you can copy/paste here directly a configuration, just remove the ids part
          '';
        };
      };
    };

    # Optional, but makes sure that when you type the make palm rejection work with keyd
    # https://github.com/rvaiya/keyd/issues/723
    environment.etc."libinput/local-overrides.quirks".text = ''
      [Serial Keyboards]
      MatchUdevType=keyboard
      MatchName=keyd virtual keyboard
      AttrKeyboardIntegration=internal
    '';

  };
}
