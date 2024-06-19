{ config, pkgs, ... }:
{
  imports = [
    ./stylix/stylix.nix
    ./hardware
    ./virualisation/docker.nix
    ./services
  ];
}
