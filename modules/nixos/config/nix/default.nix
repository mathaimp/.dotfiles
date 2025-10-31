{ config, lib, pkgs, namespace, inputs, ... }:
with lib;
with lib.${namespace};
let cfg = config.${namespace}.config.nix;
in
{
  options.${namespace}.config.nix = {
    enable = mkBoolOpt false "${namespace}.config.nix.enable";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nix-health
      nix-index
      nix-output-monitor
      nix-prefetch-git
      nixfmt-rfc-style
    ];
    nix = {
      package = pkgs.nixVersions.latest;
      gc = {
        options = "--keep 10";
        dates = "daily";
        automatic = true;
      };

      settings = {
        trusted-users = [ "root" "@wheel" ];
        sandbox = true;
        auto-optimise-store = true;
        allowed-users = [ "root" "@wheel" ];
        experimental-features = "nix-command flakes";
        http-connections = 50;
        warn-dirty = false;
        log-lines = 50;
      };
      # flake-utils-plus
      generateRegistryFromInputs = true;
      generateNixPathFromInputs = true;
      linkInputs = true;
    };

    # System AutoUpgrade
    system.autoUpgrade = {
      enable = true;
      flake = inputs.self.outPath;
      flags = [
        "-L" # print build logs
      ];
      dates = "05:00";
      randomizedDelaySec = "45min";
    };
  };
}
