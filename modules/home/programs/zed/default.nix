{
  flake.homeModules.zed =
    { pkgs
    , lib
    , ...
    }:
    {
      # home.sessionVariables = {
      #   EDITOR = "zeditor --wait";
      # };

      programs.zed-editor = {
        enable = true;
        mutableUserSettings = true;
        userSettings = builtins.fromJSON (builtins.readFile ./settings.json) // {
          ui_font_size = lib.mkForce 18.5;
          buffer_font_size = lib.mkForce 18.0;
          theme = lib.mkForce "Nord Dark";
        };
        userTasks = builtins.fromJSON (builtins.readFile ./tasks.json);
        userKeymaps = builtins.fromJSON (builtins.readFile ./keymaps.json);
        extraPackages = with pkgs; [
          bat
          fd
          nixd
          nil
          lazygit
          television
        ];
      };
    };
}
