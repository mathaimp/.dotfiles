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
  cfg = config.${namespace}.services.rclone;
in
{
  options.${namespace}.services.rclone = with types; {
    enable = mkBoolOpt false "Enable rclone";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.rclone ];
    # Run rclone config, use onedrive, name the remote KeePass
    systemd.user.timers."keepass-backup" = {
      Install.WantedBy = [ "timers.target" ];
      Timer = {
        OnBootSec = "12h";
        OnUnitActiveSec = "12h";
        Unit = "keepass-backup";
      };
    };

    systemd.user.services."keepass-backup" = {
      Unit = {
        Description = "Push KeePass Data to OneDrive";
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone sync /home/mathai/M/KeePass KeePass:KeePass \
          --config=/home/mathai/.config/rclone/rclone.conf \
          -P --log-level info \
          --log-file /tmp/rclone_sync.txt
        '';
      };
    };
  };
}
