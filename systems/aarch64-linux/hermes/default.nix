{
  pkgs,
  inputs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
{
  imports = [
    ./hardware.nix
    inputs.disko.nixosModules.disko
    ./disks.nix
  ];

  networking.hostName = "hermes";

  environment.systemPackages = with pkgs; [
    raspberrypifw
    git
    neovim
  ];

  olympus = {
    bundles = {
      server = enabled;
    };
    config = {
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
    programs = {
      sops = enabled;
    };
    services = {
      avahi = enabled;
      calibre-web = enabled;
      immich = enabled;
      tailscale = enabled;
    };
  };

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
  # DO NOT MODIFY VALUE
  system.stateVersion = "23.11";
}
