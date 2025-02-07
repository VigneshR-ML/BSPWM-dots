#!/bin/bash

wall_dir=~/Pictures/Wallpaper/
wall_path=$(find -L $wall_dir -type f | shuf -n 1)

~/.config/bspwm/exec/wallpaper/change_wallpaper.sh "$wall_path"
