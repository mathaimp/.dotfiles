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
        enableWsi = true;
        capSysNice = false;
      };

      programs.steam = {
        enable = true;
      };

      environment.systemPackages = with pkgs; [
        lutris
        piper
      ];

    };
}
