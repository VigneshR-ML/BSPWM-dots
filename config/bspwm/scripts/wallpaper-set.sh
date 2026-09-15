#!/usr/bin/env bash
#
# wallpaper-set.sh - apply a wallpaper (feh) and generate the pywal palette
#
# Refreshes the colour scheme everywhere at once:
#   - X resources (running apps that honour Xft colours)
#   - polybar palette (restarts the bars)
#   - alacritty (watches ~/.cache/wal/colors-alacritty.toml itself)
#
# Usage:
#   wallpaper-set.sh <image>
#
# The chosen image is remembered in ~/.cache/bspwm/current_wall so lock.sh
# can match the lock screen to it.
#
set -euo pipefail

image="${1:?usage: wallpaper-set.sh <image>}"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/bspwm"
POLYPALETTE="$HOME/.config/bspwm/polybar/config/colors.ini"

[ -f "$image" ] || { echo "wallpaper not found: $image" >&2; exit 1; }
mkdir -p "$CACHE"

feh --bg-fill "$image"

# Rebuild the pywal palette from the image (keep the current X wallpaper).
wal -i "$image" -n -e >/dev/null 2>&1 || true

# Push palette to the running X session + polybar.
xrdb -merge "$HOME/.cache/wal/colors.Xresources" 2>/dev/null || true
cp -f "$HOME/.cache/wal/colors-polybar.ini" "$POLYPALETTE" 2>/dev/null || true

# Remember the wallpaper for lock.sh / wallpaper-random.sh
printf '%s\n' "$image" > "$CACHE/current_wall"

# Restart bars so the new palette is picked up.
"$HOME/.config/bspwm/polybar/launch.sh" 2>/dev/null || true