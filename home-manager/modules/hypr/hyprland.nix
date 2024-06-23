{config, pkgs, lib, inputs, ... }:
{

  imports = [
    ./binds.nix
    ./lock.nix
    ./idle.nix
  ];

  #programs.hyprlock.enable = true;

  home.packages = with pkgs; [
    swww
    swayosd
    playerctl
    bc
    jq
    brightnessctl
  ];

  services.playerctld.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {

      "$terminal" = "wezterm";
      "$browser" = "firefox";
      "$file_manager" = "nemo";
      "$mainMod" = "ALT";

      input.numlock_by_default = true;

      exec-once = [
        "swww-daemon"
        "swayosd-server"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      ];

      exec = [
        "swww img ${config.stylix.image}"
      ];

      misc.disable_hyprland_logo = true;
      misc.disable_splash_rendering = true;

    };
  };
}
