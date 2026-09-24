{
  flake.homeModules.swayosd = {
    services.swayosd = {
      enable = true;
      topMargin = 0.95;
    };

    xdg.configFile."swayosd/config.toml".text = ''
      [server]
      show_percentage = true
      top_margin = 0.95
      max_volume = 150
      keyboard_backlight = true
    '';
  };
}
