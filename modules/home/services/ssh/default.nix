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

      ## FOR SAFETY, DO NOT OVERRIDE !! ##
      forwardAgent = lib.mkForce false;
      hashKnownHosts = lib.mkForce true;

      addKeysToAgent = "yes";
      serverAliveInterval = 60;
      serverAliveCountMax = 10;

      matchBlocks = {
        "github.com" = {
          user = "git";
          hostname = "github.com";
          identityFile = "${config.home.homeDirectory}/.ssh/id_github";
          identitiesOnly = true;
        };

        "blazer" = {
          user = "mathai.mathew";
          hostname = "10.2.36.164";
          identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
          identitiesOnly = true;
        };
      };
    };
    services.ssh-agent.enable = true;
  };
}
