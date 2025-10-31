{ options, config, osConfig, lib, pkgs, inputs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.swaync;
  stylixEnabled = config.${namespace}.programs.stylix.enable or false;
  stylixColors = if stylixEnabled then osConfig.lib.stylix.colors else null;
in
{
  options.${namespace}.programs.swaync = with types; {
    enable = mkBoolOpt false "Enable swaync";
  };
  config = mkIf cfg.enable {

    home.packages = with pkgs; [ libnotify swaynotificationcenter ];

    home.file.".config/swaync/configSchema.json".source = ./configSchema.json;

    home.file.".config/swaync/config.json".source = ./config.json;

    home.file.".config/swaync/style.css".text = ''
      * {
        font-size: 14px;
        font-family: "Noto Sans";
        transition: 100ms;
        box-shadow: unset;
      }

      .control-center .notification-row {
        background-color: unset;
      }

      .control-center .notification-row .notification-background .notification,
      .control-center .notification-row .notification-background .notification .notification-content,
      .floating-notifications .notification-row .notification-background .notification,
      .floating-notifications.background .notification-background .notification .notification-content {
        margin-bottom: unset;
      }

      .control-center .notification-row .notification-background .notification {
        margin-top: 0.150rem;
      }

      .control-center .notification-row .notification-background .notification box,
      .control-center .notification-row .notification-background .notification widget,
      .control-center .notification-row .notification-background .notification .notification-content,
      .floating-notifications .notification-row .notification-background .notification box,
      .floating-notifications .notification-row .notification-background .notification widget,
      .floating-notifications.background .notification-background .notification .notification-content {
        border: unset;
        border-radius: 1.159rem;
        -gtk-outline-radius: 1.159rem;

      }

      .floating-notifications.background .notification-background .notification .notification-content,
      .control-center .notification-background .notification .notification-content {
        background-color: #${stylixColors.base01};
        padding: 0.818rem;
        padding-right: unset;
        margin-right: unset;
      }

      .control-center .notification-row .notification-background .notification.low .notification-content label,
      .control-center .notification-row .notification-background .notification.normal .notification-content label,
      .floating-notifications.background .notification-background .notification.low .notification-content label,
      .floating-notifications.background .notification-background .notification.normal .notification-content label {
        color: #${stylixColors.base05};
      }

      .control-center .notification-row .notification-background .notification..notification-content image,
      .control-center .notification-row .notification-background .notification.normal .notification-content image,
      .floating-notifications.background .notification-background .notification.low .notification-content image,
      .floating-notifications.background .notification-background .notification.normal .notification-content image {
        background-color: unset;
        color: #${stylixColors.base05};
      }

      .control-center .notification-row .notification-background .notification.low .notification-content .body,
      .control-center .notification-row .notification-background .notification.normal .notification-content .body,
      .floating-notifications.background .notification-background .notification.low .notification-content .body,
      .floating-notifications.background .notification-background .notification.normal .notification-content .body {
        color: #${stylixColors.base04};
      }

      .control-center .notification-row .notification-background .notification.critical .notification-content,
      .floating-notifications.background .notification-background .notification.critical .notification-content {
        background-color: #${stylixColors.base01};
      }

      .control-center .notification-row .notification-background .notification.critical .notification-content image,
      .floating-notifications.background .notification-background .notification.critical .notification-content image{
        background-color: unset;
        color: #${stylixColors.base09};
      }

      .control-center .notification-row .notification-background .notification.critical .notification-content label,
      .floating-notifications.background .notification-background .notification.critical .notification-content label {
        color: #${stylixColors.base08};
      }

      .control-center .notification-row .notification-background .notification .notification-content .summary,
      .floating-notifications.background .notification-background .notification .notification-content .summary {
        font-family: 'Gabarito', 'Lexend', sans-serif;
        font-size: 0.9909rem;
        font-weight: 500;
      }

      .control-center .notification-row .notification-background .notification .notification-content .time,
      .floating-notifications.background .notification-background .notification .notification-content .time {
        font-family: 'Geist', 'AR One Sans', 'Inter', 'Roboto', 'Noto Sans', 'Ubuntu', sans-serif;
        font-size: 0.8291rem;
        font-weight: 500;
        margin-right: 1rem;
        padding-right: unset;
      }

      .control-center .notification-row .notification-background .notification .notification-content .body,
      .floating-notifications.background .notification-background .notification .notification-content .body {
        font-family: 'Noto Sans', sans-serif;
        font-size: 0.8891rem;
        font-weight: 400;
        margin-top: 0.310rem;
        padding-right: unset;
        margin-right: unset;
      }

      .control-center .notification-row .close-button,
      .floating-notifications.background .close-button {
        background-color: unset;
        border-radius: 100%;
        border: none;
        box-shadow: none;
        margin-right: 13px;
        margin-top: 6px;
        margin-bottom: unset;
        padding-bottom: unset;
        min-height: 20px;
        min-width: 20px;
        text-shadow: none;
      }

      .control-center .notification-row .close-button:hover,
      .floating-notifications.background .close-button:hover {
        background-color: rgba(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b}, 0.15);
      }

      .control-center {
        border-radius: 1.705rem;
        -gtk-outline-radius: 1.705rem;
        border-top: 1px solid rgba(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b}, 0.19);
        border-left: 1px solid rgba(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b}, 0.19);
        border-right: 1px solid rgba(${stylixColors.base04-rgb-r}, ${stylixColors.base04-rgb-g}, ${stylixColors.base04-rgb-b}, 0.145);
        border-bottom: 1px solid rgba(${stylixColors.base04-rgb-r}, ${stylixColors.base04-rgb-g}, ${stylixColors.base04-rgb-b}, 0.145);
        box-shadow: 0px 2px 3px rgba(${stylixColors.base01-rgb-r}, ${stylixColors.base01-rgb-g}, ${stylixColors.base01-rgb-b}, 0.45);
        margin: 7px;
        background-color: #${stylixColors.base01};
        padding: 1.023rem;
      }

      .control-center trough {
        background-color: #${stylixColors.base00};
        border-radius: 9999px;
        -gtk-outline-radius: 9999px;
        min-width: 0.545rem;
        background-color: transparent;  
      }

      .control-center slider {
        border-radius: 9999px;
        -gtk-outline-radius: 9999px;
        min-width: 0.273rem;
        min-height: 2.045rem;
        background-color: rgba(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b}, 0.31);
      }

      .control-center slider:hover {
        background-color: rgba(${stylixColors.base05-rgb-r}, ${stylixColors.base05-rgb-g}, ${stylixColors.base05-rgb-b}, 0.448);
      }

      .control-center slider:active {
        background-color: #${stylixColors.base04};
      }

      /* title widget */

      .widget-title {
        padding: 0.341rem;
        margin: unset;
      }

      .widget-title label {
        font-family: 'Gabarito', 'Lexend', sans-serif;
        font-size: 1.364rem;
        color: #${stylixColors.base05};
        margin-left: 0.941rem;
      }

      .widget-title button {
        border: unset;
        background-color: unset;
        border-radius: 1.159rem;
        -gtk-outline-radius: 1.159rem;
        padding: 0.141rem 0.141rem;
        margin-right: 0.841rem;
      }

      .widget-title button label {
        font-family: 'Gabarito', sans-serif;
        font-size: 1.0409rem;
        color: #${stylixColors.base05};
        margin-right: 0.841rem;
      }

      .widget-title button:hover {
        background-color: rgba(${stylixColors.base04-rgb-r}, ${stylixColors.base04-rgb-g}, ${stylixColors.base04-rgb-b}, 0.3);
      }

      .widget-title button:active {
        background-color: rgba(${stylixColors.base04-rgb-r}, ${stylixColors.base04-rgb-g}, ${stylixColors.base04-rgb-b}, 0.7);
      }

      /* Buttons widget */

      .widget-buttons-grid {
        border-radius: 1.159rem;
        -gtk-outline-radius: 1.159rem;
        padding: 0.341rem;
        background-color: rgba(${stylixColors.base00-rgb-r}, ${stylixColors.base00-rgb-g}, ${stylixColors.base00-rgb-b}, 0.9);
        padding: unset;
      }

      .widget-buttons-grid>flowbox {
        padding: unset;
      }

      .widget-buttons-grid>flowbox>flowboxchild>button:first-child {
        margin-left:unset ;
      }

      .widget-buttons-grid>flowbox>flowboxchild>button {
        border:none;
        background-color: unset;
        border-radius: 9999px;
        min-width: 4.522rem;
        min-height: 2.927rem;
        padding: unset;
        margin: unset;
      }

      .widget-buttons-grid>flowbox>flowboxchild>button label {
        font-family: "Materials Symbol Rounded";
        font-size: 1.3027rem;
        color: #${stylixColors.base05};
      }

      .widget-buttons-grid>flowbox>flowboxchild>button:hover {
        background-color: rgba(${stylixColors.base04-rgb-r}, ${stylixColors.base04-rgb-g}, ${stylixColors.base04-rgb-b}, 0.3);
      }

      .widget-buttons-grid>flowbox>flowboxchild>button:checked {
        /* OnePlus McClaren edition Orange accent */
        background-color: #${stylixColors.base09};
      }

      .widget-buttons-grid>flowbox>flowboxchild>button:checked label {
        color: #${stylixColors.base01};
      }


      /* Volume widget */
      .widget-volume,
      .widget-backlight,
      .widget-backlight#KB {
        background-color: #${stylixColors.base00};
        padding: 9px;
        padding-left: 18px;
        margin: 12px;
        margin-left: 12px;
        margin-right: 12px;
        border-radius: 25px; }

      .widget-backlight,
      .widget-backlight#KB {
        margin-top: 0;
        margin-bottom: 0;
        border-bottom-left-radius: 0;
        border-bottom-right-radius: 0; }

      .widget-volume {
        margin-top: 0;
        border-top-left-radius: 0;
        border-top-right-radius: 0; }

      .widget-backlight trough,
      .widget-backlight#KB trough,
      .widget-volume trough {
        /* OnePlus McClaren edition Orange accent */
        border:unset;
        background-color: rgba(${stylixColors.base04-rgb-r}, ${stylixColors.base04-rgb-g}, ${stylixColors.base04-rgb-b}, 0.4);
      }

      .widget-backlight trough slider,
      .widget-backlight#KB trough slider,
      .widget-volume trough slider {
        /* OnePlus McClaren edition Orange accent */
        color:unset;
        background-color: #${stylixColors.base09};
        border-radius: 100%;
        min-height: 1.1rem;
        min-width: 1.1rem;
      }

      /* Mpris widget */

      .widget-mpris {
        background-color: rgba(${stylixColors.base00-rgb-r}, ${stylixColors.base00-rgb-g}, ${stylixColors.base00-rgb-b}, 0.9);
        padding: 8px;
        margin: 8px;  
        border-radius: 1.159rem;
        -gtk-outline-radius: 1.159rem;  
      }

      .widget-mpris-player {
        padding: 8px;
        margin: 8px;
      }

      .widget-mpris-title {
        font-weight: bold;
        font-size: 1.25rem;
      }

      .widget-mpris-subtitle {
        font-size: 1.1rem;
      }
    '';
  };
}
