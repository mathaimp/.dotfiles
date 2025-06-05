{inputs, ...}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "/home/mathai/.config/sops/age/keys.txt";

    defaultSopsFile = "${inputs.nix-secrets}/secrets.yaml";
    validateSopsFiles = false;

    secrets = {
      "private_keys/victus" = {
        path = ".ssh/id_ed25519";
        mode = "0600";
      };
      "public_keys/victus" = {
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

      "weather/api" = {};

      "syncthing/key".sopsFile = "${inputs.nix-secrets}/syncthing.yaml";
      "syncthing/cert".sopsFile = "${inputs.nix-secrets}/syncthing.yaml";
    };
  };
}
