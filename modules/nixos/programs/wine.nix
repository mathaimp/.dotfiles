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
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };

      environment.systemPackages = with pkgs; [
        piper
      ];

    };
}
