{ inputs, ... }:
{
  flake.homeModules.spotify =
    { lib
    , pkgs
    , ...
    }:
    {
      imports = [
        inputs.spicetify-nix.homeManagerModules.default
      ];
      programs.spicetify =
        let
          spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
        in
        {
          enable = true;
          enabledExtensions = with spicePkgs.extensions; [
            adblock
            hidePodcasts
            shuffle # shuffle+ (special characters are sanitized out of extension names)
          ];
          theme = lib.mkForce spicePkgs.themes.sleek;
          colorScheme = lib.mkForce "Nord";
          # # OLD THEME
          # theme = lib.mkForce spicePkgs.themes.text;
          # colorScheme = lib.mkForce "RosePine";
        };
    };
}
