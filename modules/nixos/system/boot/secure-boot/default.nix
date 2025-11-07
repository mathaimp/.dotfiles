{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.system.boot.secure-boot;
in
{

  options.${namespace}.system.boot.secure-boot = with types; {
    enable = mkBoolOpt false "Enable Lazenboote for secure-boot.";
    wait-for-network = mkBoolOpt false "Wait for network on servers";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [
      pkgs.sbctl
    ];
    # Lanzaboote replaces systemd boot
    boot.loader.systemd-boot.enable = lib.mkForce false;

    boot.initrd.systemd.network.wait-online.enable = cfg.wait-for-network;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };
}
