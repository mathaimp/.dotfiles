{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.immich;
in
{
  options.${namespace}.services.immich = with types; {
    enable = mkBoolOpt false "Enable immich";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "immich" = { };
    };

    services.immich = {
      enable = true;

      settings = builtins.fromJSON (builtins.readFile ./immich.json);

      secretsFile = config.sops.secrets."immich".path;

      host = "0.0.0.0";
      mediaLocation = "/data/immich";

      accelerationDevices = null;

      machine-learning = {
        enable = true;
        # As immich user has no home
        environment = {
          HF_XET_CACHE = "/var/cache/immich/huggingface-xet";
        };
      };
      redis = {
        enable = true;
      };

      database = {
        enable = true;
      };
    };
    users.users.immich.extraGroups = [
      "video"
      "render"
    ];
  };
}
