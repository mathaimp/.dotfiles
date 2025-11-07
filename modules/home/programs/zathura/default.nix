{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.zathura;
  myZathura = pkgs.zathura.override {
    useMupdf = false;
  };
in
{
  options.${namespace}.programs.zathura = with types; {
    enable = mkBoolOpt false "Enable zathura";
  };
  config = mkIf cfg.enable {
    programs.zathura = {
      enable = true;
      package = myZathura;
      options = {
        recolor = true;
        recolor-reverse-video = true;
        recolor-keephue = true;
        adjust-open = "best-fit";
        pages-per-row = 1;
        scroll-page-aware = true;
        smooth-scroll = true;
        scroll-full-overlap = 0.01;
        scroll-step = 50;
        zoom-min = 10;
        render-loading = false;
        selection-clipboard = "clipboard";
      };
      mappings = {
        "e" = "toggle_fullscreen";
        "[fullscreen] e" = "toggle_fullscreen";
        "j feedkeys" = "<C-Down>";
        "k feedkeys" = "<C-Up>";
        "[fullscreen] j feedkeys" = "<C-Down>";
        "[fullscreen] k feedkeys" = "<C-Up>";
      };
    };
  };
}
