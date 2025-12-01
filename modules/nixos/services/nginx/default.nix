{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.nginx;
in
{
  options.${namespace}.services.nginx = with types; {
    enable = mkBoolOpt false "Enable nginx";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "duckdns-token" = { };
    };

    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts."immich.mathai.duckdns.org" = {
        useACMEHost = "mathai.duckdns.org";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:2283";
          proxyWebsockets = true;
          recommendedProxySettings = true;
          extraConfig = ''
            client_max_body_size 50000M;
            proxy_read_timeout   600s;
            proxy_send_timeout   600s;
            send_timeout         600s;
          '';
        };
      };

      virtualHosts."calibre.mathai.duckdns.org" = {
        useACMEHost = "mathai.duckdns.org";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8083";
          proxyWebsockets = true;
          recommendedProxySettings = true;
          extraConfig = ''
            client_max_body_size 500M;
            proxy_read_timeout   600s;
            proxy_send_timeout   600s;
            send_timeout         600s;
          '';
        };
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    security.acme.acceptTerms = true;
    security.acme.defaults.email = "ssl@mathai.duckdns.org";

    security.acme.certs."mathai.duckdns.org" = {
      domain = "mathai.duckdns.org";
      extraDomainNames = [ "*.mathai.duckdns.org" ];
      dnsProvider = "duckdns";
      dnsPropagationCheck = true;
      credentialsFile = config.sops.secrets."duckdns-token".path;
    };

    users.users.nginx.extraGroups = [ "acme" ];
  };
}
