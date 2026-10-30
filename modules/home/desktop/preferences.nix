{
  # Home-level preferences: the default terminal, browser and file manager, set by the module that
  # provides them (importing homeModules.ghostty sets preferences.terminal = "ghostty", and so on)
  # and read wherever one is needed (binds, desktop entries, ...). A value is null when nothing
  # sets it; users of it should then skip their bind/entry instead of guessing.
  flake.homeModules.preferences =
    { lib, osConfig, ... }:
    let
      command =
        description: default:
        lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          inherit default description;
        };
    in
    {
      options.preferences = {
        # The file managers are installed by NixOS modules (nautilus.nix, thunar.nix).
        fileManager = command "Command for the default file manager." (
          if osConfig.programs.nautilus-open-ank-terminal.enable then
            "nautilus"
          else if osConfig.programs.thunar.enable then
            "thunar"
          else
            null
        );
      };
    };
}
