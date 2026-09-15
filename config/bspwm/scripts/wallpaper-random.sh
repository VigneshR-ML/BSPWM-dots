#!/usr/bin/env bash
#
# wallpaper-random.sh - pick a random wallpaper and apply it
#
# Avoids immediately repeating the wallpaper that is currently set.
#
set -euo pipefail

DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Wallpaper"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/bspwm"
SET="$HOME/.config/bspwm/scripts/wallpaper-set.sh"

mapfile -t files < <(
    find -L "$DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | sort
)
[ "${#files[@]}" -gt 0 ] || { echo "no wallpapers found in $DIR" >&2; exit 1; }

current="$(cat "$CACHE/current_wall" 2>/dev/null || true)"
if [ "${#files[@]}" -gt 1 ] && [ -n "$current" ]; then
    mapfile -t files < <(printf '%s\n' "${files[@]}" | grep -Fxv "$current" || true)
fi

pick="$(printf '%s\n' "${files[@]}" | shuf -n 1)"
"$SET" "$pick"