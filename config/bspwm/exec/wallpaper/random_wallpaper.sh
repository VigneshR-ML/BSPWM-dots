#!/bin/bash

wall_dir=~/Pictures/Wallpaper/
wall_path=$(find -L "$wall_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)

if [ -z "$wall_path" ]; then
    echo "No wallpapers found in $wall_dir" >&2
    exit 1
fi

~/.config/bspwm/exec/wallpaper/change_wallpaper.sh "$wall_path"
