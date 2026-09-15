#!/usr/bin/env bash
#
# screenshot.sh - screenshots with maim + xclip
#
# Usage:
#   screenshot.sh              full screen        -> clipboard
#   screenshot.sh --region    interactive select -> clipboard
#   screenshot.sh --save      full screen        -> ~/Pictures/Screenshots/
#   screenshot.sh --save --region
#
# Combinations are order-independent. Copying to the clipboard is the macOS
# default behaviour (Cmd+Shift+3 / Cmd+Shift+4).
#
set -euo pipefail

OUT_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
save=false
mode=full

for arg in "$@"; do
    case "$arg" in
        --save)   save=true ;;
        --region) mode=region ;;
        *)
            echo "usage: $0 [--save] [--region]" >&2
            exit 2
            ;;
    esac
done

capture=("maim")
[ "$mode" = region ] && capture+=(-u -s)

if $save; then
    mkdir -p "$OUT_DIR"
    target="$OUT_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"
    "${capture[@]}" "$target"
    dunstify -r 7083 -u low "Screenshot saved" "<i>$target</i>" -t 2500
else
    "${capture[@]}" | xclip -sel clip -t image/png
    dunstify -r 7083 -u low "Screenshot copied to clipboard" "$mode" -t 1500
fi