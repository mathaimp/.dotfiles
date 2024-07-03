{config, pkgs, lib, inputs, ... }:
{

  imports = [
    ./binds.nix
    ./lock.nix
    ./idle.nix
    ./rofi/rofi.nix
    ./waybar/bar.nix
  ];

  #programs.hyprlock.enable = true;

  home.packages = with pkgs; [
    swww
    swayosd
    playerctl
    bc
    jq
    brightnessctl
    rofi-wayland
    papirus-icon-theme
    waybar
    swaynotificationcenter
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
        "brightnessctl s $(cat ~/.config/lock/bright)"
        "swww-daemon"
        "swayosd-server"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "waybar"
      ];

      exec = [
        "swww img ${config.stylix.image}"
      ];

      input.kb_options = "caps:swapescape";
      decoration.blur.enabled = false;
      decoration.drop_shadow = false;

      misc.vfr = true;
      misc.disable_hyprland_logo = true;
      misc.disable_splash_rendering = true;
      #misc.mouse_move_enables_dpms = true;
      #misc.key_press_enables_dpms = true;

    };
  };
}
