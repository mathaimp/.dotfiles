{config, ... }:
{
  hardware.nvidia = {
    powerManagement = {
      enable = true;
      finegrained = true;
    };

    dynamicBoost.enable = true;
    modesetting.enable = true;
      
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "PCI:0:6:0";
      nvidiaBusId = "PCI:0:1:0";
    };
    
    nvidiaSettings = false;
    nvidiaPersistenced = true;

    package = config.boot.kernelPackages.nvidiaPackages.beta;
    open = false;
  };
  # Enable Nvidia Drivers
  services.xserver.videoDrivers = ["nvidia"];
}
