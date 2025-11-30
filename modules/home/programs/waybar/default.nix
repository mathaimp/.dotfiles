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

      /* Stylix theme color definitions */
      @define-color background #${stylixColors.base00}; /* base00 - background */
      @define-color foreground #${stylixColors.base05}; /* base05 - foreground */
      @define-color color7 #${stylixColors.base04};     /* base04 - for general text */
      @define-color color9 #${stylixColors.base0D};     /* base0D - for accent/hover */
      @define-color border_color #${stylixColors.base03}; /* base03 - for the border */
      @define-color urgent #${stylixColors.base08};     /* base08 - red/urgent */
      @define-color warning #${stylixColors.base09};    /* base09 - orange/warning */
      @define-color success #${stylixColors.base0B};    /* base0B - green/success */
      @define-color accent #${stylixColors.base0E};     /* base0E - purple/accent */

      * {
          /* `otf-font-awesome` is required to be installed for icons */
          font-family: Cantarell, 'Font Awesome 6 Free';
          font-size: 14px;
          font-feature-settings: "tnum";
      }

      window#waybar {
          background: transparent;
          color: @foreground;
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      window#waybar.termite {
          background-color: @background;
      }

      window#waybar.chromium {
          background-color: #${stylixColors.base00};
          border: none;
      }

      button {
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: none;
          /* Avoid rounded borders under each button name */
          border: none;
          border-radius: 0;
          transition-property: none;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      button:hover {
          background: none;
          box-shadow: none;
          text-shadow: none;
          border: none;
          -gtk-icon-effect: none;
          -gtk-icon-shadow: none;
      }


      #workspaces button {
          padding: 0 5px;
          background-color: transparent;
          color: @foreground;
      }

      #workspaces button.focused {
          background-color: @border_color;
          box-shadow: inset 0 -3px @foreground;
      }

      #workspaces button.urgent {
          background-color: @urgent;
      }

      #mode {
          background-color: @border_color;
          border-bottom: 3px solid @foreground;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #wireplumber,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #scratchpad,
      #mpd {
          padding: 0 10px;
          color: @foreground;
          background-color: alpha(@background, 0.6);
          border-radius: 99px;
      }

      #window,
      #workspaces {
          margin: 0 4px;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
      }

      #clock {
          font-weight: bold;
      }

      #battery {
          margin-left: 4px;
      }

      #battery.charging, #battery.plugged {
          color: @background;
          background-color: @success;
      }

      @keyframes blink {
          to {
              background-color: @foreground;
              color: @background;
          }
      }

      #battery.critical:not(.charging) {
          background-color: @urgent;
          color: @foreground;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      label:focus {
          background-color: @background;
      }

      #cpu {
          border-radius: 99px 0px 0px 99px;
          padding: 0 0 0 10px;
          margin-left: 4px;
      }

      #memory {
          border-radius: 0px 99px 99px 0px;
      }

      #disk {
          background-color: @warning;
      }

      #backlight {
          background-color: @color9;
      }

      #network {
      }

      #network.disconnected {
          background-color: @urgent;
      }

      #taskbar {
          margin-left: 4px;
      }

      #taskbar button {
          color: @foreground;
          background-color: alpha(@background, 0.6);
      }

      #taskbar button:first-child {
          border-radius: 99px 0 0 99px;
      }

      #taskbar button:last-child {
          border-radius: 0 99px 99px 0;
      }

      #taskbar button:first-child:last-child {
          border-radius: 99px;
      }

      #taskbar button:hover {
          background-color: alpha(#${stylixColors.base01}, 0.6);
      }

      #taskbar button.active {
          background-color: alpha(#${stylixColors.base02}, 0.6);
      }

      #taskbar button.active:hover {
          background-color: alpha(@border_color, 0.6);
      }

      #pulseaudio {
          background-color: @color9;
          color: @background;
      }

      #pulseaudio.muted {
          background-color: @border_color;
          color: @foreground;
      }

      #wireplumber {
          background-color: @color9;
          color: @background;
      }

      #wireplumber.muted {
          background-color: @urgent;
      }

      #custom-media {
          background-color: @success;
          color: @background;
          min-width: 100px;
      }

      #custom-media.custom-spotify {
          background-color: @success;
      }

      #custom-media.custom-vlc {
          background-color: @warning;
      }

      #temperature {
          background-color: @warning;
      }

      #temperature.critical {
          background-color: @urgent;
      }

      #tray {
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: @urgent;
      }


      #idle_inhibitor.activated {
          background-color: @foreground;
          color: @background;
      }

      #mpd {
          background-color: @success;
          color: @background;
      }

      #mpd.disconnected {
          background-color: @urgent;
      }

      #mpd.stopped {
          background-color: @border_color;
      }

      #mpd.paused {
          background-color: #${stylixColors.base0B};
      }

      #language {
          background: @color9;
          color: @background;
          padding: 0 5px;
          margin: 0 5px;
          min-width: 16px;
      }

      #keyboard-state {
          background: @success;
          color: @background;
          padding: 0 0px;
          margin: 0 5px;
          min-width: 16px;
      }

      #keyboard-state > label {
          padding: 0 5px;
      }

      #keyboard-state > label.locked {
          background: alpha(@background, 0.2);
      }

      #scratchpad {
          background: alpha(@background, 0.2);
      }

      #scratchpad.empty {
          background-color: transparent;
      }

      #workspaces {
          padding: 7px 5px;
          color: @foreground;
          background-color: alpha(@background, 0.8);
          border-radius: 99px;

      }

      #workspaces button {
          all:unset;
          padding: 0px 5px;
          color: @foreground;
          transition: all .2s ease;
      }

      #workspaces button.active {
          color: @color9;
          border: none;
          text-shadow: 0px 0px 2px alpha(@background, .5);
      }

      #workspaces button.empty {
          color: alpha(@color7, .4);
          border: none;
          text-shadow: 0px 0px 1.5px alpha(@background, .2);
      }

      #workspaces button.empty.active {
          color: @color9;
          border: none;
          text-shadow: 0px 0px 2px alpha(@background, .5);
      }
    '';
  };
}
