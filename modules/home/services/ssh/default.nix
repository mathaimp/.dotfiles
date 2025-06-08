{ options
, config
, lib
, pkgs
, inputs
, namespace
, ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.ssh;
in
{
  options.${namespace}.services.ssh = with types; {
    enable = mkBoolOpt false "Enable SSH config and agent";
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;

      matchBlocks = {
        "github.com" = {
          user = "git";
          hostname = "github.com";
          identityFile = "${config.home.homeDirectory}/.ssh/id_github";
          identitiesOnly = true;
        };
      };

      extraConfig = ''
        AddKeysToAgent yes
      '';
    };
    services.ssh-agent.enable = true;
  };
}
