{
  config,
  osConfig,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.waybar;
  stylixEnabled = config.${namespace}.programs.stylix.enable or false;
  stylixColors = if stylixEnabled then osConfig.lib.stylix.colors else null;
in
{
  options.${namespace}.programs.waybar = with types; {
    enable = mkBoolOpt false "Enable waybar";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      waybar
    ];

    home.file.".config/waybar/config".source = ./config.jsonc;

    home.file.".config/waybar/style.css".text = ''
      #cpu,
      #memory,
      #temperature,
      #backlight {
        font-size: 11pt;
        color: #${stylixColors.base05}; }

      #battery {
        font-size: 11pt;
        color: #${stylixColors.base05}; }

      #network,
      #pulseaudio,
      #idle_inhibitor
      #bluetooth,
      #custom-notification {
        color: #${stylixColors.base05}; }

      #idle_inhibitor {
        min-width: 20pt; }

      * {
        padding: 0;
        margin: 0;
        font-family: "Noto Sans";
      }

      window#waybar {
        font-size: 13pt;
        border-radius: 8;
        border: 1px solid #${stylixColors.base03};
        background: rgba(${stylixColors.base01-rgb-r}, ${stylixColors.base01-rgb-g}, ${stylixColors.base01-rgb-b}, 0.85); }

      #cpu,
      #memory,
      #temperature,
      #backlight,
      #network,
      #bluetooth,
      #pulseaudio,
      #custom-notification {
        font-size: 11pt;
        min-width: 10pt;
        padding-left: 3px;
        padding-right: 3px;
        margin-top: 4.5px;
        margin-bottom: 4.5px; }

      #cpu,
      #network {
        font-size: 11pt;
        padding-left: 0px;
        padding-right: 14px;
        border-top-left-radius: 5px;
        border-bottom-left-radius: 5px; }

      #backlight,
      #custom-notification {
        font-size: 11pt;
        margin-right: 3px;
        padding-right: 3px;
        border-top-right-radius: 5px;
        border-bottom-right-radius: 5px; }

      #cpu {
        font-size: 0.95em;
        font-weight: bolder;
        color: #${stylixColors.base05};
        transition: 400ms;
        animation: ws_normal 20s ease-out 10; }

      #pulseaudio {
        padding-left: 0; }

      #image,
      #workspaces,
      #clock,
      #battery,
      #tray,
      #custom-power {
        padding-left: 3px;
        padding-right: 3px;
        margin-top: 4.5px;
        margin-bottom: 4.5px;
        margin-right: 6px;
        border-radius: 5px; }

      #workspaces button {
        font-size: 0;
        min-width: 7.5pt;
        min-height: 7.5pt;
        margin: 2px;
        margin-top: 7px;
        margin-bottom: 7px;
        border-radius: 50px;
        background-color: #${stylixColors.base05};
        transition: 100ms;
        animation: ws_normal 20s ease-out 10; }

      #workspaces button.empty {
        background-color: #${stylixColors.base03}; }

      #workspaces button.active {
        min-width: 18pt;
        background-color: #${stylixColors.base0D};
        transition: 100ms; }

      #battery.full {
        font-size: 11pt;
        font-size: 1.15em; }

      .modules-left {
        margin-left: 3px; }
    '';
  };
}
