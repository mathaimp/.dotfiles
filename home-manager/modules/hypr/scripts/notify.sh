#!/usr/bin/env bash

# Kill already running processes
already_running="$(ps -fC 'grep' -N | grep 'notify.sh' | wc -l)"
if [[ $already_running -gt 1 ]]; then
	pkill -f --older 1 'notify.sh'
fi

# Get path
path="$(nix eval --raw nixpkgs#papirus-icon-theme)/share/icons/Papirus/22x22@2x/panel"
low_bat=1
crit_bat=1

while [[ 0 -eq 0 ]]; do
	battery_status="$(cat /sys/class/power_supply/BAT0/status)"
	battery_charge="$(cat /sys/class/power_supply/BAT0/capacity)"

	if [[ $battery_status == 'Discharging' && $battery_charge -le 85 ]]; then
		if [[ $battery_charge -le 15 && $crit_bat -eq 1 ]]; then
			notify-send --icon="$path/battery-caution.svg" --urgency=critical "Battery critical!" "${battery_charge}%"
      crit_bat=0
			sleep 180
		elif [[ $battery_charge -le 25 && $low_bat -eq 1 && $crit_bat -eq 1 ]]; then
			notify-send --icon="$path/battery-low.svg" --urgency=critical "Battery Low!" "${battery_charge}%"
      low_bat=0
			sleep 180
    else
      sleep 60
		fi
	else
    low_batt=1
    crit_batt=1
		sleep 600
	fi
  done
  '';
  }
}
