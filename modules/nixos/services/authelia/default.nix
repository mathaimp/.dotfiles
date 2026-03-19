{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.authelia;
in
{
  options.${namespace}.services.authelia = with types; {
    enable = mkBoolOpt false "Whether or not to configure authelia.";
  };

  config = mkIf cfg.enable {
    services.authelia.instances.main = {
      enable = true;
      settings = {
        theme = "dark";
        server.address = "tcp://127.0.0.1:9091";
        session = {
          cookies = [
            {
              domain = "mathai.duckdns.org";
              authelia_url = "https://auth.mathai.duckdns.org";
              inactivity = "30m";
              expiration = "12h";
              remember_me = "1M";
            }
          ];
        };
        authentication_backend.file.path = config.sops.secrets."authelia/users".path;
        storage.local.path = "/var/lib/authelia-main/db.sqlite3";
        notifier.filesystem.filename = "/var/lib/authelia-main/notifications.txt";
        access_control.default_policy = "two_factor";

        identity_providers.oidc = {
          clients = [
            {
              client_id = "immich";
              client_name = "Immich";
              client_secret = ''{{ secret "${config.sops.secrets."authelia/immich_client_secret_hash".path}" }}'';
              public = false;
              authorization_policy = "two_factor";
              require_pkce = true;
              pkce_challenge_method = "S256";
              redirect_uris = [
                "https://immich.mathai.duckdns.org/auth/login"
                "https://immich.mathai.duckdns.org/user-settings"
                "app.immich:///oauth-callback"
              ];
              scopes = [
                "openid"
                "profile"
                "email"
              ];
              response_types = [ "code" ];
              grant_types = [ "authorization_code" ];
              token_endpoint_auth_method = "client_secret_post";
              userinfo_signed_response_alg = "none";
              access_token_signed_response_alg = "none";
              consent_mode = "implicit";
            }
          ];
        };
      };
      secrets = {
        jwtSecretFile = config.sops.secrets."authelia/jwt_secret".path;
        sessionSecretFile = config.sops.secrets."authelia/session_secret".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia/storage_key".path;
        oidcIssuerPrivateKeyFile = config.sops.secrets."authelia/oidc_private_key".path;
        oidcHmacSecretFile = config.sops.secrets."authelia/oidc_hmac_secret".path;
      };
    };

    sops.secrets = {
      "authelia/jwt_secret".owner = "authelia-main";
      "authelia/session_secret".owner = "authelia-main";
      "authelia/storage_key".owner = "authelia-main";
      "authelia/users".owner = "authelia-main";
      "authelia/oidc_hmac_secret".owner = "authelia-main";
      "authelia/oidc_private_key".owner = "authelia-main";
      "authelia/immich_client_secret_hash".owner = "authelia-main";
      "authelia/jellyfin_client_secret_hash".owner = "authelia-main";
    };

    services.caddy.virtualHosts."auth.mathai.duckdns.org".extraConfig = ''
      encode zstd gzip
      reverse_proxy localhost:9091
    '';
  };
}
