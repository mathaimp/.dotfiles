{
  flake.nixosModules.hostAres =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot = {
        initrd = {
          availableKernelModules = [
            "nvme"
            "xhci_pci"
            "uas"
            "usbhid"
            "sd_mod"
          ];
          kernelModules = [ ];
          # Setup LUKS encrypted drive
          luks.devices."nixos-root".device = "/dev/disk/by-uuid/d83c53f7-8f7b-48ad-96fc-09d825f0bd94";
        };
        kernelModules = [ "kvm-amd" ];
        extraModulePackages = [ ];

        # For hibernation with swapfile and luks encryption
        kernelParams = [
          "resume=/dev/mapper/nixos-root"
          "resume_offset=533760"
        ];
        resumeDevice = "/dev/mapper/nixos-root";
      };

      fileSystems = {

        "/" = {
          device = "/dev/disk/by-uuid/b71a234e-6ef0-4fe4-b592-f254aa147858";
          fsType = "btrfs";
          options = [
            "subvol=@"
            "noatime"
            "compress=zstd:1"
            "ssd"
            "discard=async"
            "space_cache=v2"
            "commit=120"
          ];
        };

        "/nix" = {
          device = "/dev/disk/by-uuid/b71a234e-6ef0-4fe4-b592-f254aa147858";
          fsType = "btrfs";
          options = [
            "subvol=@nix"
            "noatime"
            "compress=zstd:1"
            "ssd"
            "discard=async"
            "space_cache=v2"
            "commit=120"
          ];
        };

        "/swap" = {
          device = "/dev/disk/by-uuid/b71a234e-6ef0-4fe4-b592-f254aa147858";
          fsType = "btrfs";
          options = [
            "subvol=@swap"
            "noatime"
          ];
        };

        "/persist" = {
          device = "/dev/disk/by-uuid/b71a234e-6ef0-4fe4-b592-f254aa147858";
          fsType = "btrfs";
          options = [
            "subvol=@persist"
            "noatime"
            "compress=zstd:1"
            "ssd"
            "discard=async"
            "space_cache=v2"
            "commit=120"
          ];
        };

        "/boot" = {
          device = "/dev/disk/by-uuid/9B90-F167";
          fsType = "vfat";
          options = [
            "fmask=0022"
            "dmask=0022"
          ];
        };
      };

      swapDevices = [
        {
          device = "/swap/swapfile";
          size = 16 * 1024;
        }
      ];

      networking.useDHCP = lib.mkDefault true;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware = {
        enableRedistributableFirmware = true;
        cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        bluetooth.enable = lib.mkDefault true;
      };
    };
}
