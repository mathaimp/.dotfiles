{
  osConfig,
  config,
  lib,
  namespace,
  inputs,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.sops;
in
{
  options.${namespace}.programs.sops = with types; {
    enable = mkBoolOpt false "Enable sops";
  };

  config = mkIf cfg.enable {
    sops = {
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      defaultSopsFile = "${inputs.nix-secrets}/${osConfig.networking.hostName}.yaml";
      validateSopsFiles = false;

      secrets = {
        "private_keys/host" = {
          path = ".ssh/id_ed25519";
          mode = "0600";
        };
        "public_keys/host" = {
          path = ".ssh/id_ed25519.pub";
          mode = "0644";
        };

        "private_keys/github" = {
          path = ".ssh/id_github";
          mode = "0600";
        };

        "public_keys/github" = {
          path = ".ssh/id_github.pub";
          mode = "0644";
        };
      };
    };
  };
}
