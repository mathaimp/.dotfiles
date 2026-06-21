{
  flake.homeModules.stylix =
    { pkgs
    , ...
    }:
    {
      stylix = {
        enable = true;
        autoEnable = true;
        icons = {
          enable = true;
          package = pkgs.papirus-icon-theme.override {
            color = "bluegrey";
          };
          light = "Papirus-Light";
          dark = "Papirus-Dark";
        };
        targets = {
          firefox = {
            colorTheme.enable = true;
            profileNames = [ "default" ];
          };
          ghostty.enable = false;
          kitty.enable = false;
          waybar.enable = false;
          hyprlock.enable = false;
          neovim.enable = false;
          neovide.enable = false;
          tmux.enable = false;
        };
      };
    };
}
