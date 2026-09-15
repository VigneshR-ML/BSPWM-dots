#!/usr/bin/env bash
#
# wallpaper-pick.sh - browse wallpapers with rofi and apply the selection
#
# Shows thumbnails as a grid (rofi icons) so you can spot the right image.
# Requires rofi >= 1.7.5 topic-dmenu; older rofi shows a readable file list.
#
set -euo pipefail

DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Wallpaper"
THEME="$HOME/.config/bspwm/rofi/wallpaper.rasi"
SET="$HOME/.config/bspwm/scripts/wallpaper-set.sh"

mapfile -t files < <(
    find -L "$DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | sort -r
)
[ "${#files[@]}" -gt 0 ] || { echo "no wallpapers found in $DIR" >&2; exit 1; }

# Show just the file names (strip the directory), remember the source.
name="$(printf '%s\n' "${files[@]##*/}" |
    rofi -dmenu -p "Wallpaper" -theme "$THEME")" || exit 1
[ -n "$name" ] || exit 1

for f in "${files[@]}"; do
    if [ "${f##*/}" = "$name" ]; then
        "$SET" "$f"
        exit 0
    fi
done

echo "selection not found: $name" >&2
exit 1