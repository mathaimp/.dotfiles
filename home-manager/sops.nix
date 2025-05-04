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
        path = "/home/mathai/.ssh/id_ed25519";
      };
      "public_keys/victus" = {
        path = "/home/mathai/.ssh/id_ed25519.pub";
      };

      "syncthing/key".sopsFile = "${inputs.nix-secrets}/syncthing.yaml";
      "syncthing/cert".sopsFile = "${inputs.nix-secrets}/syncthing.yaml";
    };
  };
}
