{
  config,
  lib,
  pkgs,
  inputs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.spotify;
in
{
  options.${namespace}.programs.spotify = with types; {
    enable = mkBoolOpt false "Enable Spotify";
  };
  config = mkIf cfg.enable {
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
        theme = lib.mkForce spicePkgs.themes.ziro;
        colorScheme = lib.mkForce "rose-pine";
        # # OLD THEME
        # theme = lib.mkForce spicePkgs.themes.text;
        # colorScheme = lib.mkForce "RosePine";
      };
  };
}
