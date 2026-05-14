{
  flake.nixosModules.wine =
    {
      pkgs,
      ...
    }:
    {
      programs.gamemode.enable = true;
      services.ratbagd.enable = true;
      programs.gamescope = {
        enable = true;
        capSysNice = false;
      };

      environment.systemPackages = with pkgs; [
        lutris
        piper
        # steam
      ];

    };
}
