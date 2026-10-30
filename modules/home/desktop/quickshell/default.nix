{ ... }:
{
  flake.homeModules.quickshell =
    {
      osConfig,
      pkgs,
      ...
    }:
    let
      colors = osConfig.lib.stylix.colors.withHashtag;
    in
    {
      home.packages = [
        # External monitor brightness over DDC/CI (config/Brightness.qml).
        pkgs.ddcutil
        # BlueZ pairing agent, driven by config/BluetoothAgent.qml over stdio.
        (pkgs.writers.writePython3Bin "qs-bt-agent" {
          libraries = [ pkgs.python3Packages.dbus-fast ];
          flakeIgnore = [
            "E501"
            "F722" # dbus-fast type signatures look like bad annotations
            "F821"
          ];
        } (builtins.readFile ./bt-agent.py))
      ];

      programs.quickshell = {
        enable = true;
        configs.default = ./config;
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
        # Lucide icon font (see config/Glyphs.qml).
        iconFont = "${pkgs.lucide}/share/fonts/truetype/Lucide.ttf";
      };

      # Render on the AMD iGPU via Mesa only; otherwise glvnd also loads the Nvidia EGL driver (~34 MB).
      systemd.user.services.quickshell.Service.Environment = [
        "__EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json"
      ];
    };
}
