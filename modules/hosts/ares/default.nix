{ inputs, self, ... }:
{
  flake.nixosConfigurations.ares = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.hostAres
    ];
  };

  flake.nixosModules.hostAres =
    { pkgs, ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.default
        inputs.nixos-hardware.nixosModules.omen-16-n0280nd

        self.nixosModules.common-bundle
        self.nixosModules.user

        self.nixosModules.hyprland
        # self.nixosModules.niri
        self.nixosModules.cloudflare-warp
        self.nixosModules.bluetooth
        self.nixosModules.btrfs
        self.nixosModules.nvidia
        self.nixosModules.sleep

        self.nixosModules.plymouth
        self.nixosModules.stylix

        self.nixosModules.avahi
        self.nixosModules.docker
        self.nixosModules.keyd
        self.nixosModules.tailscale
        self.nixosModules.printing

        self.nixosModules.wine

        self.nixosModules.automatic-timezone
        self.nixosModules.battery
        self.nixosModules.secure-boot
      ];

      preferences = {
        user = {
          name = "mathai";
          extraGroups = [
            "networkmanager"
            "wheel"
            "dialout"
          ];
        };
        secure-boot.wait-for-network = false;
      };

      boot.kernelPackages = pkgs.linuxPackages_latest;
      boot.loader.systemd-boot.configurationLimit = 20; # Not enough space in /boot =(

      home-manager = {
        users.mathai = self.homeModules.mathai-ares;
        useUserPackages = true;
        useGlobalPkgs = true;
      };

      networking.hostName = "ares";
      system.stateVersion = "24.05";
    };
}
