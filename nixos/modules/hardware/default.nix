{ config, pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "resume=/dev/mapper/nixos-root" "resume_offset=533760" ];
  boot.resumeDevice = "/dev/mapper/nixos-root";

  imports = [
    ./nvidia.nix
    ./pstate.nix
    ./zenpower.nix
  ];

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  hardware = {
    # Enable all firmware regardless of license.
    enableAllFirmware = true;

    # Enable firmware with a license allowing redistribution.
    enableRedistributableFirmware = true;

    # update the CPU microcode for Intel processors.
    cpu.amd.updateMicrocode = true;

    # Enable OpenGL drivers
    opengl = {
      enable = true;
      # driSupport = true;
      driSupport32Bit = true;
    };
  };

}
