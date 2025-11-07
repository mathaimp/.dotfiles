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
  cfg = config.${namespace}.config.user;
in
{
  options.${namespace}.config.user = with types; {
    name = mkOpt str "mathai" "The name to use for the user account.";
    fullName = mkOpt str "Mathai Mathew" "The full name of the user.";
    email = mkOpt str "mathewp8616@gmail.com" "The email of the user.";
    extraGroups = mkOpt (listOf str) [ ] "Groups for the user to be assigned.";
    extraOptions = mkOpt attrs { } (mdDoc "Extra options passed to `users.users.<name>`.");
    sshKeys = mkOpt (listOf str) [ ] "List of SSH keys to authorize for the user.";
  };

  config = mkMerge [
    # Base configuration (always applied)
    {
      programs.zsh = enabled;
      users.users.${cfg.name} = {
        isNormalUser = true;
        home = "/home/${cfg.name}";
        group = "users";
        shell = pkgs.zsh;
        uid = 1000;
        extraGroups = cfg.extraGroups;
        openssh.authorizedKeys.keys = cfg.sshKeys;
      };
    }

    # Conditional sops configuration
    (mkIf config.${namespace}.programs.sops.enable {
      users.mutableUsers = false;

      sops.secrets."${cfg.name}-password".neededForUsers = true;
      sops.secrets."root-password".neededForUsers = true;

      users.users.${cfg.name} = {
        hashedPasswordFile = config.sops.secrets."${cfg.name}-password".path;
      };

      users.users.root = {
        hashedPasswordFile = config.sops.secrets."root-password".path;
      };
    })
  ];
}
