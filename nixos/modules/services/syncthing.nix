{ config, ... }:
{
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

  services.syncthing = {
    enable = true;
    dataDir = "/home/mathai";
    openDefaultPorts = true;
    configDir = "/home/mathai/.config/syncthing";
    user = "mathai";
    group = "users";
    guiAddress = "0.0.0.0:8384";
    key = config.sops.secrets."syncthing/key".path;
    cert = config.sops.secrets."syncthing/cert".path;
    settings.gui = {
      user = "mathai";
    };
    settings.devices = {
      "phone" = { 
        id = "ZXNAFHS-2A5YFPF-BJHK4NT-S25VLEA-X7VLZYR-LMDRQHD-XJKAM23-ADG6KAQ"; 
        name = "phone";
      }; 
    };
    settings.folders = {
      "KeePass" = {
        path = "/home/mathai/M/KeePass";
        devices = [ "phone" ];
        versioning = { 
          type = "simple"; 
          params = { 
            keep = "10";
          }; 
        };
      };
    };
  };
}
