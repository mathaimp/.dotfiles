{
  flake.homeModules.niri =
    {
      pkgs,
      ...
    }:
    {
      imports = [
        ./_binds.nix
        ./_settings.nix
        ./_rules.nix
      ];
      # Uses pkgs.niri, the same package as the NixOS `programs.niri` module.
      # xwayland-satellite is put on PATH by the module and started by niri on demand.
      wayland.windowManager.niri.enable = true;

      home.packages = with pkgs; [
        brightnessctl
        wl-clipboard
      ];

      services.playerctld.enable = true;
    };
}
