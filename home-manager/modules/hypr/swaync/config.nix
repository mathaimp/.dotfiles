{ ... }:
{
  home.file.".config/swaync/config.json".text = ''
{
  "$schema": "$XDG_CONFIG_HOME/swaync/configSchema.json",
  "control-center-height": 2,
  "control-center-layer": "overlay",
  "control-center-margin-bottom": 20,
  "control-center-margin-left": 0,
  "control-center-margin-right": 10,
  "control-center-margin-top": 20,
  "control-center-width": 500,
  "cssPriority": "application",
  "control-center-positionX":"right",
  "control-center-positionY":"center",
  "fit-to-screen": true,
  "hide-on-action": false,
  "hide-on-clear": true,
  "image-visibility": "when-available",
  "keyboard-shortcuts": true,
  "layer": "layer",
  "notification-body-image-height": 100,
  "notification-body-image-width": 200,
  "notification-icon-size": 40,
  "notification-inline-replies": true,
  "notification-visibility": {},
  "notification-window-width": 400,
  "positionX": "right",
  "positionY": "top",
  "script-fail-notify": true,
  "scripts": {},
  "timeout": 10,
  "timeout-critical": 0,
  "timeout-low": 5,
  "transition-time": 100,
  "widget-config": {
    "buttons-grid": {
      "actions": [
        {
          "label": " ",
          "type": "toggle",
          "active": true,
          "command": "sh -c '[[ $SWAYNC_TOGGLE_STATE == true ]] && nmcli radio wifi on || nmcli radio wifi off'",
          "update-command": "sh -c '[[ $(nmcli radio wifi) == \"enabled\" ]] && echo true || echo false'"
        },
        {
          "active": true,
          "command": "blueman-manager",
          "label": "",
          "type": "button"
        },
        {
          "active": false,
          "command": "swaync-client -d",
          "label": " ",
          "type": "toggle"
        },
        {
          "active":false,
          "command":"grimshot savecopy anything",
          "label":"󰄀",
          "type": "button"
        },
        {
          "active": false,
          "command": "${builtins.toString ./.}/../scripts/powermenu.sh",
          "label": "",
          "type": "button"
        }
      ]
    },
    "mpris": {
      "image-radius": 12,
      "image-size": 96
    },
    "title": {
      "text": "Notifications",
      "button-text": "󰎟 Clear",
      "clear-all-button": true
    },
    "volume": {
      "label": "  ",
        "show-per-app": true,
        "show-per-app-icon": true,
        "show-per-app-label":true
    },
    "backlight": {
      "label": "  ",
      "device": "amdgpu_bl1",
      "min": 0
    },
    "backlight#KB": {
      "label": "  ",
      "device": "amdgpu_bl2",
      "min": 0
    }
},

  "widgets": [
    "buttons-grid",
    "backlight",
    "backlight#KB",
    "volume",
    "title",
    "notifications",
    "mpris"
  ]
}
  '';
}
