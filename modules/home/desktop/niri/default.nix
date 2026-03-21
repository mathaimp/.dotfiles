{
  inputs,
  config,
  pkgs,
  lib,
  libEx,
  namespace,
  ...
}:
with lib;
with libEx.${namespace};
let
  cfg = config.${namespace}.desktop.niri;
in
{
  imports = [
    ./binds.nix
    ./settings.nix
    ./rules.nix
  ];

  options.${namespace}.desktop.niri = with types; {
    enable = mkBoolOpt false "Enable niri";
  };
  config = mkIf cfg.enable {

    programs.niri = {
      enable = true;
      # Use the niri-flake's own unstable package rather than relying on
      # a separate unstable nixpkgs channel.
      package = inputs.niri-flake.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
    };

    home.packages = with pkgs; [
      brightnessctl
      wl-clipboard
    ];

    systemd.user.services.xwayland-satellite = {
      Unit = {
        Description = "Xwayland Satellite";
        After = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
        Restart = "on-failure";
      };
    };

    services.playerctld.enable = true;
  };
}
