#!/usr/bin/env bash
#
# lock.sh - lock the screen with the current wallpaper (dimmed) via i3lock
#
# Reuses ~/.cache/bspwm/current_wall (written by wallpaper-set.sh) so the lock
# background always matches the active wallpaper.
#
set -euo pipefail

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/bspwm"
IMG="$CACHE/lock.png"
wall="$(cat "$CACHE/current_wall" 2>/dev/null || true)"

mkdir -p "$CACHE"

if [ -n "$wall" ] && [ -f "$wall" ]; then
    # Match the resolution of the primary output so very large wallpapers
    # don't blow up memory usage. Defaults to the MacBook panel (2x scale).
    geom="$(xrandr --current 2>/dev/null | awk '/ connected/ {print $4; exit}' | cut -d+ -f1)"
    res="${geom:-1512x982}"

    magick "$wall" -resize "${res}^" -gravity center -extent "$res" \
        -filter Lanczos -fill black -colorize 30% "$IMG"
    exec i3lock --nofork -i "$IMG"
fi

exec i3lock --nofork