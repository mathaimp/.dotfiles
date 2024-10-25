{ config, pkgs, ... }:
{

  imports = [
    ./binds.nix
    ./lock.nix
    ./idle.nix
    ./rofi/rofi.nix
    ./waybar/bar.nix
    ./swaync/swaync.nix
  ];

  gtk.iconTheme.name = "Papirus-Dark";

  home.packages = with pkgs; [
    swww
    swayosd
    playerctl
    bc
    jq
    brightnessctl
    rofi-wayland
    papirus-icon-theme
    libnotify
    waybar
    swaynotificationcenter
    networkmanagerapplet
    sway-contrib.grimshot
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
        "${builtins.toString ./.}/scripts/notify.sh"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "waybar"
        "swaync"
        "nm-applet"
      ];

      env = [
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
      ];

      exec = [
        "swww img ${config.stylix.image}"
      ];

      windowrule = [
        "opacity 0.9 0.9,(wezterm)$"
      ];

      layerrule = [
        "blur,waybar"
      ];

      general.gaps_out = 10;
      general.gaps_in = 3;

      input.kb_options = "ctrl:nocaps";
      decoration.blur.enabled = true;
      decoration.drop_shadow = false;
      decoration.rounding = 10;

      misc.vfr = true;
      misc.disable_hyprland_logo = true;
      misc.disable_splash_rendering = true;
      #misc.mouse_move_enables_dpms = true;
      #misc.key_press_enables_dpms = true;

    };
  };
}
