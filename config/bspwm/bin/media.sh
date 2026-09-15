#!/usr/bin/env bash
#
# media.sh - media player controls (playerctl: Spotify, vlc, firefox, ...)
#
# Usage:
#   media.sh play-pause | toggle
#   media.sh next | previous | stop
#
# Shows the currently playing track in a notification.
#
set -euo pipefail

action="${1:-play-pause}"

case "$action" in
    play-pause | toggle) playerctl play-pause ;;
    next)                 playerctl next ;;
    previous | prev)      playerctl previous ;;
    stop)                 playerctl stop ;;
    *)
        echo "usage: $0 {play-pause|next|previous|stop}" >&2
        exit 2
        ;;
esac

track="$(playerctl metadata --format '{{artist}} — {{title}}' 2>/dev/null || true)"
if [ -n "$track" ]; then
    dunstify -r 7084 -u low "♪ $track" -t 2000
fi