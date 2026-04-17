{
  inputs,
  self,
  ...
}:
{
  flake.nixosConfigurations.hermes = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.hostHermes
    ];
  };

  flake.nixosModules.hostHermes =
    { pkgs, ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.default
        inputs.nixos-hardware.nixosModules.raspberry-pi-4

        self.diskoConfigurations.hermes

        self.nixosModules.server-bundle
        self.nixosModules.user

        self.nixosModules.sops

        self.nixosModules.avahi
        self.nixosModules.bazarr
        self.nixosModules.caddy
        self.nixosModules.calibre-web
        self.nixosModules.cloudflare-warp
        self.nixosModules.immich
        self.nixosModules.jellyfin
        self.nixosModules.jellyseerr
        self.nixosModules.glance
        self.nixosModules.prowlarr
        self.nixosModules.qbittorent
        self.nixosModules.radarr
        self.nixosModules.sonarr
        self.nixosModules.tailscale
        self.nixosModules.vaultwarden
      ];

      preferences = {
        user = {
          name = "mathai";
          extraGroups = [
            "networkmanager"
            "wheel"
            "dialout"
          ];
          sshKeys = [
            # Ares public key
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBqAjPS8h1F+nNPJmU6nQErFPBU3GTbAhf36gXrVWePF mathai"
          ];
        };
      };

      environment.systemPackages = with pkgs; [
        raspberrypifw
        git
        neovim
      ];

      boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;

      home-manager = {
        users.mathai = self.homeModules.mathai-hermes;
        useUserPackages = true;
        useGlobalPkgs = true;
      };

      networking.hostName = "hermes";
      system.stateVersion = "24.05";
    };
}
