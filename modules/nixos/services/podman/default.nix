{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.podman;
in
{
  options.${namespace}.services.podman = with types; {
    enable = mkBoolOpt false "Enable podman";
  };

  config = mkIf cfg.enable {
    virtualisation.containers.enable = true;
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    environment.systemPackages = with pkgs; [ podman-compose ];

    hardware.nvidia-container-toolkit.enable = builtins.any (
      driver: driver == "nvidia"
    ) config.services.xserver.videoDrivers;
  };
}
