{ lib, config, pkgs, ... }:
with config.lib.stylix.colors;
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
    systemd.variables = ["--all"];
    settings = {

      "$terminal" = "kitty";
      "$browser" = "firefox";
      "$file_manager" = "thunar";
      "$mainMod" = "ALT";

      input.numlock_by_default = true;

      exec-once = [
        "brightnessctl s $(cat ~/.dotfiles/home-manager/modules/hypr/scripts/bright)"
        "swww-daemon"
        "swayosd-server"
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

      layerrule = [
        "blur,waybar"
      ];
      windowrule = [
        "workspace special:magic silent, title:Passwords - KeePassXC"
        "workspace special:magic silent, title:Passwords.kdbx [Locked] - KeePassXC"
        "opacity 0.95 override 0.95 override 0.95 override, class:kitty"
      ];

      general.gaps_out = 6;
      general.gaps_in = 3;
      general."col.active_border" = lib.mkForce "rgb(${base03})";
      general."col.inactive_border" = lib.mkForce "rgb(${base02})";

      input.kb_options = "ctrl:nocaps";
      decoration.blur.enabled = true;
      decoration.rounding = 10;

      misc.vfr = true;
      misc.disable_hyprland_logo = true;
      misc.disable_splash_rendering = true;
      misc.mouse_move_enables_dpms = true;
      misc.key_press_enables_dpms = true;

    };
  };
}
