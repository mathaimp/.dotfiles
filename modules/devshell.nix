{
  perSystem = { pkgs, ... }: {
    # nix fmt
    formatter = pkgs.nixpkgs-fmt;

    # nix develop
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        nixpkgs-fmt
        deadnix
        statix
        nil
      ];
    };
  };
}
