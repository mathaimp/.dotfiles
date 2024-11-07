{ config, ... }:
{
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  hardware.nvidia-container-toolkit.enable = builtins.any (driver: driver == "nvidia") config.services.xserver.videoDrivers;
}
