{inputs, config, ...}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {

    defaultSopsFile = "${inputs.nix-secrets}/secrets.yaml";
    validateSopsFiles = false;

    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets = {
      "syncthing/pass" = {
        sopsFile = "${inputs.nix-secrets}/syncthing.yaml";
        owner = "mathai";
      };
      "syncthing/key".sopsFile = "${inputs.nix-secrets}/syncthing.yaml";
      "syncthing/cert".sopsFile = "${inputs.nix-secrets}/syncthing.yaml";
      "device_id/nothing2".sopsFile = "${inputs.nix-secrets}/syncthing.yaml";
    };
    templates = {
      "phone".content = ''${config.sops.placeholder."device_id/nothing2"}'';
      "syncpass".content = ''${config.sops.placeholder."syncthing/pass"}'';
    };
  };
}
