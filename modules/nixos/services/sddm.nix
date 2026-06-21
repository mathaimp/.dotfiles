{ inputs, ... }:
{
  flake.nixosModules.sddm =
    { config
    , pkgs
    , ...
    }:
    let
      stylixColors = config.lib.stylix.colors;
    in
    {

      services.displayManager.sddm = {
        enable = true;
        # wayland.enable = true;
        package = pkgs.kdePackages.sddm;
        theme = "pixie";
        settings = {
          Theme = {
            CursorTheme = config.stylix.cursor.name;
            CursorSize = config.stylix.cursor.size;
          };
        };
        extraPackages = with pkgs; [
          kdePackages.qtsvg
          kdePackages.qtdeclarative
          kdePackages.qt5compat
        ];
      };
      environment.systemPackages = [
        (inputs.pixie-sddm.packages.${pkgs.stdenv.hostPlatform.system}.pixie-sddm.override {
          background = config.stylix.image;
          avatar = ../../home/desktop/noctalia/face.png;
          primaryColor = "#${stylixColors.base0D}";
          accentColor = "#${stylixColors.base0D}";
          backgroundColor = "#${stylixColors.base00}";
          autoColor = false;
          textColor = "#${stylixColors.base05}";
          fontFamily = "${config.stylix.fonts.sansSerif.name}";
          fontSize = config.stylix.fonts.sizes.applications;
        })
      ];
    };
}
