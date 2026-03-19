{
  config,
  lib,
  pkgs,
  namespace,
  inputs,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.config.nix;
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
    ];
    nix = {
      package = pkgs.nixVersions.latest;
      gc = {
        options = "--keep 10";
        dates = "daily";
        automatic = true;
      };

      settings = {
        extra-substituters = [
          "https://nix-community.cachix.org"
          "https://colmena.cachix.org"
        ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
        ];
        trusted-users = [
          "root"
          "@wheel"
        ];
        sandbox = true;
        auto-optimise-store = true;
        allowed-users = [
          "root"
          "@wheel"
        ];
        experimental-features = "nix-command flakes";
        http-connections = 50;
        warn-dirty = false;
        log-lines = 50;
      };
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
