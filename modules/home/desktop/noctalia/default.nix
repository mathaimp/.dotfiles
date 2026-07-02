{ inputs, ... }:
{
  flake.homeModules.noctalia =
    {
      ...
    }:
    {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      programs.noctalia = {
        enable = true;
        settings = builtins.readFile ./noctalia.toml;
      };
    };
}
