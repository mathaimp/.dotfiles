{ config, pkgs, ... }:
{
  imports = [
    ./shell/shell.nix
    ./hypr/hyprland.nix
    ./music/spicetify.nix
  ];
}
