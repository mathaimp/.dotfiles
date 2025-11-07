{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = true;
  };
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "usbhid"
    "usb_storage"
  ];
  boot.kernelParams = [
    "8250.nr_uarts=1"
    "console=tyAMA0,115200"
    "console=tty1"
    "cma=128M"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  hardware.enableRedistributableFirmware = true;
}
