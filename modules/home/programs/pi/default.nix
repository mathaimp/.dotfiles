{
  flake.homeModules.pi =
    {
      pkgs,
      ...
    }:
    {
      programs.pi-coding-agent = {
        enable = true;
        extraPackages = [
          pkgs.nodejs
          pkgs.ripgrep
          pkgs.socat
          pkgs.bubblewrap
        ];
        context = ./context.md;
      };
    };
}
