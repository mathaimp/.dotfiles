{ inputs, ... }:
{
  flake.nixosModules.stylix =
    { pkgs
    , ...
    }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];
      stylix = {
        enable = true;
        autoEnable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 24;
        };
        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrainsMono Nerd Font Mono";
          };
          sansSerif = {
            package = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro-nerd;
            name = "SFProDisplay Nerd Font";
          };
          serif = {
            package = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro-nerd;
            name = "SFProDisplay Nerd Font";
          };
          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
          sizes = {
            applications = 13;
            desktop = 13;
            popups = 13;
            terminal = 13;
          };
        };
        image = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/iruzo/wp/main/desktop-nord-dark-koi.png";
          sha256 = "sha256-/ybcRRleApkw3JXQTZgOsYznRwS7pIRvZYp0Vyls7i4=";
        };
        polarity = "dark";
      };
    };
}
