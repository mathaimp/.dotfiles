{ options
, config
, lib
, pkgs
, inputs
, namespace
, ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.stylix;
in
{
  options.${namespace}.programs.stylix = with types; {
    enable = mkBoolOpt false "Enable stylix";
  };

  # No need to import Stylix (should follow nixos conf)
  config = mkIf cfg.enable {
    home.packages = [ pkgs.papirus-icon-theme ];
    gtk.iconTheme.name = "Papirus-Dark";

    stylix = {
      enable = true;

      autoEnable = true;

      iconTheme = {
        enable = true;
        package = pkgs.papirus-icon-theme;
        light = "Papirus-Light";
        dark = "Papirus-Dark";
      };

      targets = {
        kitty.enable = false;
        waybar.enable = false;
        hyprlock.enable = false;
        neovim.enable = false;
	# Neovide diabled otherwise adds stuff to neovim conf
	neovide.enable = false;
        tmux.enable = false;
      };
    };
  };
}
