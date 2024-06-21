{config, pkgs, lib, inputs, ... }:
{

  imports = [
    ./binds.nix
    ./lock.nix
  ];

  #programs.hyprlock.enable = true;

  home.packages = with pkgs; [
    swww
    swayosd
    playerctl
  ];

  services.playerctld.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {

      "$terminal" = "wezterm";
      "$browser" = "firefox";
      "$file_manager" = "nemo";
      "$mainMod" = "SUPER";

      input.numlock_by_default = true;

      exec-once = [
        "swww-daemon"
        "swayosd-server"
      ];

      exec = [
        "swww img ${config.stylix.image}"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      ];

      misc.disable_hyprland_logo = true;
      misc.disable_splash_rendering = true;

    };
  };
}
