{
  flake.homeModules.atuin =
    { config
    , ...
    }:
    {
      sops.secrets = {
        "atuin-key" = {
          path = "${config.home.homeDirectory}/.local/share/atuin/key";
        };
      };

      programs.atuin = {
        enable = true;
        flags = [ "--disable-up-arrow" ];
        settings = {
          auto_sync = true;
          sync_frequency = "5m";
          sync_address = "https://api.atuin.sh";
          search_mode = "fuzzy";
          style = "compact";
          invert = true;
          workspaces = true;
          secrets_filter = true;
          history_filter = [
            "^cd \\.\\.$"
            "^ls$"
            "^exit$"
          ];
        };
      };
    };
}
