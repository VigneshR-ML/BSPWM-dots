#!/usr/bin/env bash
#
# brightness.sh - display brightness control
#
# Apple Silicon Macs expose the built-in panel as:
#   /sys/class/backlight/apple-panel-bl  (driven via brightnessctl)
#
# Usage:
#   brightness.sh --inc   raise brightness by 10%
#   brightness.sh --dec   lower brightness by 10%
#   brightness.sh         show current brightness
#
set -euo pipefail

STEP=10
NOTIFY_ID=7082

notify() {
    dunstctl close-all
    local cur max pct icon
    cur="$(brightnessctl g)"
    max="$(brightnessctl m)"
    pct=$((cur * 100 / max))

    if   [ "$pct" -le 25 ]; then icon="󰃞"
    elif [ "$pct" -le 50 ]; then icon="󰃝"
    elif [ "$pct" -le 75 ]; then icon="󰃟"
    else icon="󰃠"; fi

    dunstify -r "$NOTIFY_ID" -h int:value:"$pct" "$icon Brightness: $pct%" -t 1200
}

case "${1:-}" in
    --inc) brightnessctl set +"$STEP"% ;;
    --dec) brightnessctl set "$STEP"%- ;;
    "")    ;;
    *)
        echo "usage: $0 {--inc|--dec}" >&2
        exit 2
        ;;
esac

notify