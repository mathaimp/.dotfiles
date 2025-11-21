{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.sddm;
  stylixEnabled = config.${namespace}.programs.stylix.enable or false;
  stylixColors = if stylixEnabled then config.lib.stylix.colors else null;
in
{
  options.${namespace}.services.sddm = with types; {
    enable = mkBoolOpt false "Enable sddm";
  };

  config = mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      wayland = {
        enable = true;
        compositor = "weston";
      };
      autoNumlock = true;
      package = pkgs.kdePackages.sddm;
      enableHidpi = true;
      theme = "sddm-astronaut-theme";
      settings = {
        Theme = {
          CursorTheme = lib.mkIf stylixEnabled config.stylix.cursor.name;
          CursorSize = lib.mkIf stylixEnabled config.stylix.cursor.size;
        };
      };
      extraPackages = with pkgs; [
        kdePackages.qtsvg
        kdePackages.qtvirtualkeyboard
        kdePackages.qtmultimedia
      ];
    };
    environment.systemPackages = with pkgs; [
      (sddm-astronaut.override {
        themeConfig = {
          Font = if stylixEnabled then "${config.stylix.fonts.sansSerif.name}" else "Sans Serif";
          FontSize = if stylixEnabled then config.stylix.fonts.sizes.applications else 13;
          Background = if stylixEnabled then "${config.stylix.image}" else None;
          FullBlur = "true";
          BlurMax = "64";
          Blur = "1.0";

          HeaderTextColor = "#${stylixColors.base05}";
          DateTextColor = "#${stylixColors.base05}";
          TimeTextColor = "#${stylixColors.base05}";

          LoginFieldBackgroundColor = "#${stylixColors.base00}";
          PasswordFieldBackgroundColor = "#${stylixColors.base00}";
          LoginFieldTextColor = "#${stylixColors.base05}";
          PasswordFieldTextColor = "#${stylixColors.base05}";
          UserIconColor = "#${stylixColors.base05}";
          PasswordIconColor = "#${stylixColors.base05}";

          PlaceholderTextColor = "#${stylixColors.base04}";
          WarningColor = "#${stylixColors.base0A}";

          LoginButtonTextColor = "#${stylixColors.base05}";
          LoginButtonBackgroundColor = "#${stylixColors.base00}";
          SystemButtonsIconsColor = "#${stylixColors.base05}";
          SessionButtonTextColor = "#${stylixColors.base05}";
          VirtualKeyboardButtonTextColor = "#${stylixColors.base05}";

          DropdownTextColor = "#${stylixColors.base05}";
          DropdownSelectedBackgroundColor = "#${stylixColors.base02}";
          DropdownBackgroundColor = "#${stylixColors.base00}";

          HighlightTextColor = "#${stylixColors.base0D}";
          HighlightBackgroundColor = "#${stylixColors.base04}";
          HighlightBorderColor = "#${stylixColors.base04}";

          HoverUserIconColor = "#${stylixColors.base0D}";
          HoverPasswordIconColor = "#${stylixColors.base0D}";
          HoverSystemButtonsIconsColor = "#${stylixColors.base0D}";
          HoverSessionButtonTextColor = "#${stylixColors.base0D}";
          HoverVirtualKeyboardButtonTextColor = "#${stylixColors.base0D}";
        };
      })
    ];
  };
}
