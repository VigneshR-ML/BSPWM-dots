#!/usr/bin/env bash
cmd="${1:-}"
NMCLI=/usr/bin/nmcli
DUNSTIFY=/usr/bin/dunstify

ssid="$("$NMCLI" -t -f NAME,TYPE connection show --active | awk -F: '$2=="802-11-wireless"{print $1; exit}')"
sig="$("$NMCLI" -t -f IN-USE,SIGNAL dev wifi | awk -F: '/^\*/{print $2; exit}')"

if [ -n "$ssid" ]; then
  if [ "$cmd" = "notify" ]; then
    "$DUNSTIFY" -a polybar -r 9997 -u normal "$ssid" "Wi-Fi: Connected"
    exit 0
  fi
  if   [ "$sig" -ge 80 ]; then ram="󰤨"
  elif [ "$sig" -ge 60 ]; then ram="󰤥"
  elif [ "$sig" -ge 40 ]; then ram="󰤢"
  elif [ "$sig" -ge 20 ]; then ram="󰤟"
  else ram="󰤯"
  fi
  echo "$ram con"
else
  if [ "$cmd" = "notify" ]; then
    "$DUNSTIFY" -a polybar -r 9997 -u normal "Wi-Fi" "Not connected"
    exit 0
  fi
  echo "󰤭 dis"
fi
