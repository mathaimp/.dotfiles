{
  config,
  lib,
  namespace,
  inputs,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.firefox;
in
{
  options.${namespace}.programs.firefox = {
    enable = mkBoolOpt false "Enable Firefox";
  };

  config = mkIf cfg.enable {

    home.sessionVariables = {
      BROWSER = "firefox";
    };

    programs.firefox = {
      enable = true;
      profiles.default = {
        id = 0;
        name = "Default";
        containersForce = true;
        containers = {
          google = {
            id = 1;
            color = "blue";
            icon = "fingerprint";
          };
          meta = {
            id = 2;
            color = "orange";
            icon = "tree";
          };
          shopping = {
            id = 3;
            color = "green";
            icon = "cart";
          };
          banking = {
            id = 4;
            color = "red";
            icon = "dollar";
          };
          social = {
            id = 5;
            color = "pink";
            icon = "circle";
          };
          development = {
            id = 6;
            color = "purple";
            icon = "chill";
          };
        };

        settings = {
          # Enable HTTPS-Only Mode
          "dom.security.https_only_mode" = true;
          "dom.security.https_only_mode_ever_enabled" = true;

          # Privacy settings
          "privacy.donottrackheader.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.partition.network_state.ocsp_cache" = true;

          # Disable all sorts of telemetry
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.ping-centre.telemetry" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.hybridContent.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.updatePing.enabled" = false;

          # As well as Firefox 'experiments'
          "experiments.activeExperiment" = false;
          "experiments.enabled" = false;
          "experiments.supported" = false;
          "network.allow-experiments" = false;

          # Disable Pocket Integration
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
          "extensions.pocket.enabled" = false;
          "extensions.pocket.api" = "";
          "extensions.pocket.oAuthConsumerKey" = "";
          "extensions.pocket.showHome" = false;
          "extensions.pocket.site" = "";

          # Restore previous session
          "browser.startup.page" = 3;
          # Vertical Tabs
          "sidebar.verticalTabs" = true;
          "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;
          "sidebar.visibility" = "always-show";

          # Enable extensions by default
          "extensions.autoDisableScopes" = 0;

          # toolbar
          "browser.uiCustomization.state" =
            "{\"placements\":{\"widget-overflow-fixed-list\":[],\"nav-bar\":[\"sidebar-button\",\"back-button\",\"forward-button\",\"stop-reload-button\",\"vertical-spacer\",\"customizableui-special-spring1\",\"urlbar-container\",\"customizableui-special-spring2\",\"downloads-button\",\"unified-extensions-button\",\"firefox-view-button\",\"alltabs-button\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[],\"vertical-tabs\":[\"tabbrowser-tabs\"],\"PersonalToolbar\":[\"personal-bookmarks\"]},\"dirtyAreaCache\":[\"nav-bar\",\"PersonalToolbar\",\"unified-extensions-area\",\"toolbar-menubar\",\"TabsToolbar\",\"vertical-tabs\"],\"currentVersion\":23,\"newElementCount\":9}";

          # Home
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.topSitesRows" = 2;

          # Disable password saving prompts
          "signon.rememberSignons" = false;
          "signon.autofillForms" = false;
          "signon.generation.enabled" = false;
        };

        bookmarks = {
          force = true;
          settings = [
            {
              toolbar = true;
              bookmarks = [
                {
                  name = "Wikipedia";
                  tags = [ "wiki" ];
                  keyword = "wiki";
                  url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
                }
                {
                  name = "GMail";
                  tags = [ "mail" ];
                  url = "https://mail.google.com/mail/u/0/";
                }
                {
                  name = "MyNixos";
                  tags = [ "wiki" ];
                  url = "https://mynixos.com";
                }
                {
                  name = "Github";
                  tags = [ "code" ];
                  url = "https://github.com";
                }
                {
                  name = "Youtube";
                  tags = [ "media" ];
                  url = "https://www.youtube.com";
                }
              ];
            }
          ];
        };

        extensions = {
          force = true;
          packages = with inputs.firefox-addons.packages."${pkgs.stdenv.hostPlatform.system}"; [
            ublock-origin
            sponsorblock
            darkreader
            youtube-shorts-block
            zotero-connector
            keepassxc-browser
            multi-account-containers
            temporary-containers
          ];
          settings = {
            "uBlock0@raymondhill.net".settings = {
              selectedFilterLists = [
                "ublock-filters"
                "ublock-badware"
                "ublock-privacy"
                "ublock-unbreak"
                "ublock-quick-fixes"
              ];
            };

            "{c607c8df-14a7-4f28-894f-29e8722976af}".settings = {
              preferences = {
                automaticMode = {
                  active = true;
                  newTab = "created";
                };
                container = {
                  numberMode = "hide";
                  namePrefix = "tmp";
                  color = "toolbar";
                  colorRandom = false;
                  icon = "circle";
                  iconRandom = false;
                  removal = 900000;
                };
              };
            };
          };
        };

      };
      policies = {
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            default_area = "menupanel";
            private_browsing = true;
          };
          "sponsorBlocker@ajay.app" = {
            default_area = "menupanel";
          };
          "@testpilot-containers" = {
            default_area = "menupanel";
          };
          "zotero@chnm.gmu.edu" = {
            default_area = "navbar";
          };
          "keepassxc-browser@keepassxc.org" = {
            default_area = "navbar";
          };
        };
      };
    };
  };
}
