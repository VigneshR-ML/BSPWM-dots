#!/usr/bin/env bash
#
# layout.sh - toggle keyboard layout between US and Russian
#
# Works on any keyboard (including Apple). Current layout is read from
# setxkbmap so this stays in sync with what X is actually using.
#
set -euo pipefail

current() {
    setxkbmap -query | awk '
        /^layout/ {
            sub(/[,].*$/, "", $2)   # strip everything after the first comma
            print $2
        }'
}

case "$(current)" in
    ru) setxkbmap us,ru; label="US" ;;
    *)  setxkbmap ru,us; label="RU" ;;
esac

dunstctl close-all
dunstify -u low "Keyboard layout: $label" -t 1200