{ options, config, lib, pkgs, inputs, namespace, ... }:
with lib;
with lib.${namespace};
let 
  cfg = config.${namespace}.programs.stylix;
in
{
  options.${namespace}.programs.stylix = with types; {
    enable = mkBoolOpt false "Enable stylix";
  };
  
  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (options ? stylix) {
      stylix = {
        enable = true;
        autoEnable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
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
            package = inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd;
            name = "SFProDisplay Nerd Font";
          };
          serif = {
            package = inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd;
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
        image = ./cloud-coffee.jpg;
        polarity = "dark";
      };
    })
  ]);
}
