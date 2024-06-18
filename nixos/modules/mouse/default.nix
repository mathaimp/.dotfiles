{ config, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.callPackage ./mouse.nix {
      version = "1c9662043f4a11af26537e394bbd90e38994066a";
    }
  ];
}
