{
  flake.homeModules.office-bundle =
    {
      pkgs,
      ...
    }:
    {
      programs.vesktop.enable = true;

      home.packages = with pkgs; [
        tsukimi
        evince
        libreoffice
        obsidian
        signal-desktop
      ];
    };
}
