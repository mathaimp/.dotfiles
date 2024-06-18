{ config, pkgs, ... }:
{
  stylix.enable = true;
  stylix.image = ./astro.jpg;
  stylix.polarity = "dark";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  stylix.fonts.sizes.applications = 10;
  stylix.fonts.sizes.desktop = 10;
  stylix.fonts.sizes.popups = 10;
  stylix.cursor.package = pkgs.bibata-cursors;
  stylix.cursor.name = "Bibata-Modern-Classic";
  stylix.cursor.size = 24;
}
