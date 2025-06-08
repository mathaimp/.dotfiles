{ pkgs, lib, namespace, ... }:
with lib;
with lib.${namespace};
{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "ares";

  olympus = {
    bundles = {
      common = enabled;
    };
    config = {
      user = {
        name = "mathai";
        extraGroups = [
          "networkmanager"
          "wheel"
          "dialout"
        ];
      };
    };
    desktop.hyprland = enabled;
    hardware = {
      bluetooth = enabled;
      btrfs = enabled;
      nvidia = enabled;
      sleep = enabled;
    };

    programs = {
      stylix = enabled;
      wine = enabled;
    };

    services = {
      docker = enabled;
      keyd = enabled;
      printing = enabled;
    };

    system = {
      automatic-timezone = enabled;
      battery = enabled;
      boot.secure-boot = {
        enable = true;
        wait-for-network = false;
      };
    };
  };

  # DO NOT MODIFY VALUE
  system.stateVersion = "24.05";
}
