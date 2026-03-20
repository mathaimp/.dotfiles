{
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
{
  options.${namespace}.programs.home-manager = with types; {
    extraOptions = mkOpt attrs { } "${namespace}.programs.home-manager.extraOptions";
  };

  # Auto Import and setup home-manager
  config = {
    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
    };
  };
}
