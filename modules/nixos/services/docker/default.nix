{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let cfg = config.${namespace}.services.docker;
in
{
  options.${namespace}.services.docker = with types; {
    enable = mkBoolOpt false "Enable docker";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ xorg.xhost ];
    virtualisation.docker = {
      enable = true;
      storageDriver = mkIf (config.${namespace}.hardware.btrfs.enable) "btrfs";
      rootless = {
        enable = true;
        setSocketVariable = true;
        daemon.settings = { "dns" = [ "8.8.8.8" "1.1.1.1" ]; };
      };
    };
    hardware.nvidia-container-toolkit.enable =
      builtins.any (driver: driver == "nvidia")
        config.services.xserver.videoDrivers;
  };
}
