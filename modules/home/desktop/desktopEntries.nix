{
  flake.homeModules.desktopEntries =
    {
      config,
      lib,
      ...
    }:
    let
      inherit (config.preferences) terminal;
    in
    {
      xdg = {
        enable = true;
        userDirs.enable = true;
        # Needs a terminal to run in.
        desktopEntries = lib.mkIf (terminal != null) {
          "nvim" = {
            name = "Neovim";
            comment = "Edit text files";
            exec = "${terminal} -e nvim %F";
            icon = "nvim";
            terminal = false;
            type = "Application";
            categories = [
              "Utility"
              "TextEditor"
            ];
          };
        };
      };
    };
}
