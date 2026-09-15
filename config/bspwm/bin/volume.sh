#!/usr/bin/env bash
#
# volume.sh - speaker/headphone volume control (PipeWire / PulseAudio)
#
# Usage:
#   volume.sh --inc     raise volume by 5%
#   volume.sh --dec     lower volume by 5%
#   volume.sh --toggle  mute/unmute
#
set -euo pipefail

STEP=5
NOTIFY_ID=7081

notify() {
    dunstctl close-all
    local sink volume muted icon
    sink="$(pactl get-default-sink)"
    volume="$(pactl get-sink-volume "$sink" | awk '{print int($5)}')"
    muted="$(pactl get-sink-mute "$sink" | awk '{print $2}')"

    if [ "$muted" = "yes" ]; then
        icon="󰖁"
        dunstify -r "$NOTIFY_ID" -h int:value:0 "$icon Volume: muted" -t 1200
        return
    fi

    if   [ "$volume" -le 33 ]; then icon="󰕿"
    elif [ "$volume" -le 66 ]; then icon="󰖀"
    else icon="󰕾"; fi

    dunstify -r "$NOTIFY_ID" -h int:value:"$volume" "$icon Volume: $volume%" -t 1200
}

case "${1:-}" in
    --inc)    pactl set-sink-volume @DEFAULT_SINK@ +"$STEP"% ;;
    --dec)    pactl set-sink-volume @DEFAULT_SINK@ -"$STEP"% ;;
    --toggle) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
    *)
        echo "usage: $0 {--inc|--dec|--toggle}" >&2
        exit 2
        ;;
esac

notify