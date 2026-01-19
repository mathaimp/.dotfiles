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
  cfg = config.${namespace}.services.prowlarr;
  dataDir = "/data/prowlarr";
in
{
  options.${namespace}.services.prowlarr = with types; {
    enable = mkBoolOpt false "Enable prowlarr";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      prowlarr
      dotnetCorePackages.aspnetcore_8_0
    ];

    systemd = {
      services.prowlarr = {
        description = "Prowlarr";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          User = config.services.jellyfin.user;
          Group = config.services.jellyfin.group;
          ExecStart = "${lib.getExe pkgs.prowlarr} -nobrowser -data=${dataDir}";
          Restart = "on-failure";
        };
      };
    };
    networking.firewall.allowedTCPPorts = [ 9696 ];

    services.flaresolverr = {
      enable = true;
      openFirewall = true;
    };
  };
}
