{ inputs, ... }:
{
  flake.homeModules.quickshell =
    {
      config,
      osConfig,
      pkgs,
      ...
    }:
    let
      colors = osConfig.lib.stylix.colors.withHashtag;
    in
    {
      # External monitor brightness over DDC/CI (config/Brightness.qml).
      home.packages = [ pkgs.ddcutil ];

      programs.quickshell = {
        enable = true;
        # Symlink straight to the repo so QML edits live-reload without a rebuild.
        configs.default = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/modules/home/desktop/quickshell/config";
        activeConfig = "default";
        systemd.enable = true;
      };

      # Read by config/Theme.qml.
      xdg.configFile."quickshell/theme.json".text = builtins.toJSON {
        bg = colors.base00;
        container = colors.base01;
        surface = colors.base02;
        fg = colors.base05;
        muted = colors.base03;
        accent = colors.base0D;
        occupied = colors.base0F;
        warning = colors.base0A;
        critical = colors.base08;
        font = osConfig.stylix.fonts.sansSerif.name;
        # Noctalia v5's Tabler-based icon font (has a few icons official Tabler lacks, e.g. wifi-3).
        iconFont = "${inputs.noctalia}/assets/fonts/noctalia-tabler.ttf";
      };

      # Render on the AMD iGPU via Mesa only; otherwise glvnd also loads the Nvidia EGL driver (~34 MB).
      systemd.user.services.quickshell.Service.Environment = [
        "__EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json"
      ];
    };
}
