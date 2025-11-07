{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.system.locale;
in
{
  options.${namespace}.system.locale = {
    enable = mkBoolOpt false "${namespace}.config.locale.enable";
  };
  config = mkIf cfg.enable {
    i18n = {
      defaultLocale = "en_US.UTF-8";

      extraLocaleSettings = {
        LC_ADDRESS = "en_IN";
        LC_IDENTIFICATION = "en_IN";
        LC_MEASUREMENT = "en_IN"; # Metric system
        LC_MONETARY = "en_IN"; # Indian Rupees
        LC_NAME = "en_IN";
        LC_NUMERIC = "en_IN"; # Indian number format (1,00,000)
        LC_PAPER = "en_IN"; # A4 paper size
        LC_TELEPHONE = "en_IN";
        LC_TIME = "en_IN"; # 24-hour time format
      };
    };

    time.timeZone = lib.mkDefault "Asia/Kolkata";

    # Enable your existing US keyboard configuration
    services.xserver.xkb.layout = "us";
  };
}
