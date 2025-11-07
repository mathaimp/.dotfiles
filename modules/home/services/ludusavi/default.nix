{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.ludusavi;
in
{
  options.${namespace}.services.ludusavi = with types; {
    enable = mkBoolOpt false "Enable ludusavi";
  };
  config = mkIf cfg.enable {
    services.ludusavi = {
      enable = true;
      frequency = "daily";
      backupNotification = true;

      settings = {
        backup = {
          path = "~/Games/ludusavi-backup/";
        };
        language = "en-US";
        restore = {
          path = "~/Games/ludusavi-backup/";
        };
        roots = [
          {
            path = "~/.local/share/Steam";
            store = "steam";
          }
          {
            path = "~/.local/share/lutris";
            store = "lutris";
          }
        ];
        theme = "dark";
      };
    };
  };
}
