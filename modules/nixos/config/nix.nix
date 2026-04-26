{ inputs, ... }:
{
  flake.nixosModules.nix =
    { pkgs
    , ...
    }:
    {
      environment.systemPackages = with pkgs; [
        nix-health
        nix-index
        nix-output-monitor
        nix-prefetch-git
      ];

      nixpkgs.config.allowUnfree = true;

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
          ];
          extra-trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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
