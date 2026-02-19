{
  config,
  lib,
  libEx,
  namespace,
  ...
}:
with lib;
with libEx.${namespace};
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
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          ## FOR SAFETY, DO NOT OVERRIDE !! ##
          forwardAgent = lib.mkForce false;
          hashKnownHosts = lib.mkForce true;

          addKeysToAgent = "yes";
          serverAliveInterval = 60;
          serverAliveCountMax = 10;
          compression = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "auto";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";

          setEnv = {
            TERM = "xterm-256color";
          };

        };

        "github.com" = {
          user = "git";
          hostname = "ssh.github.com";
          identityFile = "${config.home.homeDirectory}/.ssh/id_github";
          identitiesOnly = true;
          port = 443;
        };

        "blazer" = {
          user = "mathai.mathew";
          hostname = "10.2.36.177";
          identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
          identitiesOnly = true;
        };

        "neon" = {
          user = "mathai_mathew";
          hostname = "10.2.36.169";
          identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
          identitiesOnly = true;
        };

        "ada" = {
          user = "mathai.mathew";
          hostname = "10.4.24.24";
          identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
          identitiesOnly = true;
        };

        "void" = {
          user = "mathai.mathew";
          hostname = "10.2.36.213";
          identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
          identitiesOnly = true;
        };
      };
    };
    services.ssh-agent.enable = true;
  };
}
