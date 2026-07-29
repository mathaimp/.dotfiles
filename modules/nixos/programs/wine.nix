{
  flake.nixosModules.wine =
    {
      pkgs,
      ...
    }:
    {
      services.ratbagd.enable = true;

      programs.steam = {
        enable = true;
      };

      environment.systemPackages = with pkgs; [
        piper
      ];

    };
}
