{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.glance;
in
{
  options.${namespace}.services.glance = with types; {
    enable = mkBoolOpt false "Enable glance";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "glance" = { };
    };

    services.glance = {
      enable = true;
      environmentFile = config.sops.secrets."glance".path;
      settings = {
        server = {
          host = "0.0.0.0";
        };
        branding = {
          hide-footer = true;
        };
        pages = [
          {
            name = "Startpage";
            hide-desktop-navigation = true;
            center-vertically = true;
            head-widgets = [
              {
                type = "search";
                search-engine = "google";
                target = "_self";
              }
            ];
            columns = [
              {
                size = "small";
                widgets = [
                  {
                    type = "weather";
                    location = "\${LOC}";
                    units = "metric";
                    hour-format = "12h";
                  }
                  {
                    type = "clock";
                    time-format = "12h";
                    date-format = "d MMMM yyyy";
                    show-seconds = true;
                    show-timezone = true;
                    timezone = "\${TIMEZONE}";
                  }
                  {
                    type = "markets";
                    markets = [
                      {
                        symbol = "^GSPC";
                        name = "S&P 500";
                        chart-link = "https://www.tradingview.com/chart/?symbol=INDEX:^GSPC";
                        symbol-link = "https://finance.yahoo.com/quote/^GSPC";
                      }
                      {
                        symbol = "^DJI";
                        name = "Dow Jones";
                        chart-link = "https://www.tradingview.com/chart/?symbol=INDEX:^DJI";
                        symbol-link = "https://finance.yahoo.com/quote/^DJI";
                      }
                      {
                        symbol = "^IXIC";
                        name = "NASDAQ";
                        chart-link = "https://www.tradingview.com/chart/?symbol=INDEX:^IXIC";
                        symbol-link = "https://finance.yahoo.com/quote/^IXIC";
                      }
                      {
                        symbol = "^NSEI";
                        name = "Nifty 50";
                        chart-link = "https://www.tradingview.com/chart/?symbol=NSE:^NSEI";
                        symbol-link = "https://finance.yahoo.com/quote/^NSEI";
                      }
                      {
                        symbol = "^BSESN";
                        name = "Sensex";
                        chart-link = "https://www.tradingview.com/chart/?symbol=BSE:^BSESN";
                        symbol-link = "https://finance.yahoo.com/quote/^BSESN";
                      }
                    ];
                  }
                ];
              }
              {
                size = "full";
                widgets = [
                  {
                    type = "monitor";
                    cache = "1m";
                    title = "Services";
                    sites = [
                      {
                        title = "Immich";
                        url = "https://immich.mathai.duckdns.org/";
                        icon = "si:immich";
                      }
                      {
                        title = "Calibre";
                        url = "https://calibre.mathai.duckdns.org/";
                        icon = "si:calibreweb";
                      }
                      {
                        title = "Nextcloud";
                        url = "https://cloud.mathai.duckdns.org/";
                        icon = "si:nextcloud";
                      }
                      {
                        title = "Vaultwarden";
                        url = "https://vault.mathai.duckdns.org/";
                        icon = "si:vaultwarden";
                      }
                    ];
                  }
                  {
                    type = "server-stats";
                    servers = [
                      {
                        type = "local";
                        name = "Hermes";
                        hide-mountpoints-by-default = true;
                        mountpoints = {
                          "/" = {
                            hide = false;
                          };
                        };
                      }
                    ];
                  }
                  {
                    type = "bookmarks";
                    groups = [
                      {
                        title = "General";
                        links = [
                          {
                            title = "Gmail";
                            url = "https://mail.google.com/mail/u/0/";
                          }
                          {
                            title = "Amazon";
                            url = "https://www.amazon.com/";
                          }
                          {
                            title = "Github";
                            url = "https://github.com/";
                          }
                        ];
                      }
                      {
                        title = "Entertainment";
                        color = "10 70 50";
                        links = [
                          {
                            title = "YouTube";
                            url = "https://www.youtube.com/";
                          }
                          {
                            title = "Netflix";
                            url = "https://www.netflix.com/";
                          }
                          {
                            title = "Prime Video";
                            url = "https://www.primevideo.com/";
                          }
                          {
                            title = "Disney+";
                            url = "https://www.disneyplus.com/";
                          }
                        ];
                      }
                      {
                        title = "Social";
                        color = "200 50 50";
                        links = [
                          {
                            title = "Reddit";
                            url = "https://www.reddit.com/";
                          }
                          {
                            title = "Twitter";
                            url = "https://twitter.com/";
                          }
                          {
                            title = "Instagram";
                            url = "https://www.instagram.com/";
                          }
                        ];
                      }
                    ];
                  }
                  {
                    type = "videos";
                    channels = [
                      "UCHnyfMqiRRG1u-2MsSQLbXA" # Veritasium
                      "UCBJycsmduvYEL83R_U4JriQ" # Marques Brownlee
                      "UCRYOj4DmyxhBVrdvbsUwmAA" # optimum
                      "UCODHrzPMGbNv67e84WDZhQQ" # fern
                      "UCtYKe7-XbaDjpUwcU5x0bLg" # neo
                      "UCy0tKL1T7wFoYcxCe0xjN6Q" # Technology Connections
                    ];
                  }
                  {
                    type = "custom-api";
                    title = "Astronomy Picture of the Day";
                    cache = "1d";
                    url = "https://api.nasa.gov/planetary/apod?api_key=\${NASA}";
                    headers = {
                      Accept = "application/json";
                    };
                    template = "{{- if eq (.JSON.String \"media_type\") \"image\" -}}\n  <div style=\"display:flex; flex-direction:column; align-items:center; width:100%; padding:8px; box-sizing:border-box;\">\n    <!-- Clickable title -->\n    <p class=\"color-primary\" style=\"margin:0 0 8px; text-align:center;\">\n      <a \n        href=\"https://apod.nasa.gov/apod/astropix.html\" \n        target=\"_blank\" \n        rel=\"noopener noreferrer\"\n        style=\"color: inherit; text-decoration: none;\"\n      >\n        {{ .JSON.String \"title\" }}\n      </a>\n    </p>\n\n    <!-- Image -->\n    <img\n      src=\"{{ .JSON.String \"url\" }}\"\n      alt=\"{{ .JSON.String \"title\" }}\"\n      style=\"max-width:100%; height:auto; display:block; border-radius:4px;\"\n    />\n\n    <!-- Explanation dropdown -->\n    <details style=\"width:100%; margin-top:12px;\">\n      <summary class=\"color-highlight size-h5\" style=\"cursor:pointer;\">\n         Show Explanation\n      </summary>\n      <p class=\"color-highlight size-h5\" style=\"margin-top:8px; text-align:left; line-height:1.4;\">\n        {{ .JSON.String \"explanation\" }}\n      </p>\n    </details>\n  </div>\n{{- else -}}\n  <p class=\"color-negative\" style=\"text-align:center;\">\n    No image available today.\n  </p>\n{{- end }}";
                  }
                ];
              }
              {
                size = "small";
                widgets = [
                  {
                    type = "custom-api";
                    title = "Immich stats";
                    cache = "1d";
                    url = "https://immich.mathai.duckdns.org/api/server/statistics";
                    headers = {
                      x-api-key = "\${IMMICH}";
                      Accept = "application/json";
                    };
                    template = "<div class=\"flex justify-between text-center\">\n  <div>\n      <div class=\"color-highlight size-h3\">{{ .JSON.Int \"photos\" | formatNumber }}</div>\n      <div class=\"size-h6\">PHOTOS</div>\n  </div>\n  <div>\n      <div class=\"color-highlight size-h3\">{{ .JSON.Int \"videos\" | formatNumber }}</div>\n      <div class=\"size-h6\">VIDEOS</div>\n  </div>\n  <div>\n      <div class=\"color-highlight size-h3\">{{ div (.JSON.Int \"usage\" | toFloat) 1073741824 | toInt | formatNumber }}GB</div>\n      <div class=\"size-h6\">USAGE</div>\n  </div>\n</div>";
                  }
                  {
                    type = "to-do";
                  }
                  {
                    type = "custom-api";
                    title = "Random Fact";
                    cache = "3h";
                    url = "https://uselessfacts.jsph.pl/api/v2/facts/random";
                    template = ''<p class="size-h4 color-paragraph">{{ .JSON.String "text" }}</p>'';
                  }
                  {
                    type = "calendar";
                    first-day-of-week = "monday";
                  }
                ];
              }
            ];
          }
        ];
      };
    };

    services.nginx.virtualHosts."mathai.duckdns.org" = {
      useACMEHost = "mathai.duckdns.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          client_max_body_size 50M;
          proxy_read_timeout   600s;
          proxy_send_timeout   600s;
          send_timeout         600s;
        '';
      };
    };
  };
}
