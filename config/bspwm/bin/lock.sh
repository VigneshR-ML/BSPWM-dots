#!/bin/bash

IMG=~/.cache/i3lock-bg.png
wall=$(cat ~/.config/bspwm/exec/wallpaper/current_wall 2>/dev/null)

if [ -n "$wall" ] && [ -f "$wall" ]; then
    magick "$wall" -filter Lanczos -fill black -colorize 30% "$IMG"
fi

exec i3lock --nofork -i "$IMG" 2>/dev/null || exec i3lock --nofork