{ pkgs, lib, ... }:
{
  environment.systemPackages = [
    pkgs.sbctl
  ];
  # Lanzaboote replaces systemd boot
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
}
