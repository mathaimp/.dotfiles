{ options, config, lib, pkgs, inputs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.stylix;
in
{
  options.${namespace}.programs.stylix = with types; {
    enable = mkBoolOpt false "Enable Stylix integration.";
  };
  
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [ pkgs.papirus-icon-theme ];
      gtk.iconTheme.name = "Papirus-Dark";
    }
    # Only configure stylix if the module is imported
    (optionalAttrs (options ? stylix) {
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
          ghostty.enable = false;
          kitty.enable = false;
          waybar.enable = false;
          hyprlock.enable = false;
          neovim.enable = false;
          neovide.enable = false;
          tmux.enable = false;
        };
      };
    })
  ]);
}
