{
  lib,
  config,
  namespace,
  ...
}:
let
  inherit (lib)
    types
    mkIf
    mkDefault
    mkMerge
    ;
  inherit (lib.${namespace}) mkOpt;

  cfg = config.${namespace}.config.user;

  home-directory = if cfg.name == null then null else "/home/${cfg.name}";
in
{
  options.${namespace}.config.user = {
    enable = mkOpt types.bool true "Whether to configure the user account.";
    name = mkOpt (types.nullOr types.str) (config.snowfallorg.user.name or "mathai"
    ) "The user account.";

    fullName = mkOpt types.str "Mathai Mathew" "The full name of the user.";
    email = mkOpt types.str "mathewp8616@gmail.com" "The email of the user.";

    home = mkOpt (types.nullOr types.str) home-directory "The user's home directory.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.name != null;
          message = "${namespace}.user.name must be set";
        }
        {
          assertion = cfg.home != null;
          message = "${namespace}.user.home must be set";
        }
      ];

      home = {
        username = mkDefault cfg.name;
        homeDirectory = mkDefault cfg.home;
      };
    }
  ]);
}
