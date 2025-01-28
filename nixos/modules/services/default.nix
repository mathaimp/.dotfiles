{config, ... }:
{
  imports = [
    ./daemon.nix
    ./pipewire.nix
    ./wine.nix
  ];
}
