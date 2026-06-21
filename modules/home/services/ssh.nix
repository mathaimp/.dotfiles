{
  flake.homeModules.ssh =
    { config
    , lib
    , ...
    }:
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
          "*" = {
            ## FOR SAFETY, DO NOT OVERRIDE !! ##
            ForwardAgent = lib.mkForce false;
            HashKnownHosts = lib.mkForce true;

            AddKeysToAgent = "yes";
            ServerAliveInterval = 60;
            ServerAliveCountMax = 10;
            Compression = false;
            UserKnownHostsFile = "~/.ssh/known_hosts";
            ControlMaster = "auto";
            ControlPath = "~/.ssh/master-%r@%n:%p";
            ControlPersist = "no";

            SetEnv = {
              TERM = "xterm-256color";
            };
          };

          "github.com" = {
            User = "git";
            HostName = "ssh.github.com";
            IdentityFile = "${config.home.homeDirectory}/.ssh/id_github";
            IdentitiesOnly = true;
            Port = 443;
          };

          "blazer" = {
            User = "mathai.mathew";
            HostName = "10.2.36.177";
            IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
            IdentitiesOnly = true;
          };

          "neon" = {
            User = "mathai_mathew";
            HostName = "10.2.36.169";
            IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
            IdentitiesOnly = true;
          };

          "ada" = {
            User = "mathai.mathew";
            HostName = "10.4.24.24";
            IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
            IdentitiesOnly = true;
          };

          "void" = {
            User = "mathai.mathew";
            HostName = "10.2.36.213";
            IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
            IdentitiesOnly = true;
          };

          "hermes" = {
            User = "mathai";
            HostName = "100.119.255.54";
            IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
            IdentitiesOnly = true;
          };
        };
      };
      services.ssh-agent.enable = true;
    };
}
