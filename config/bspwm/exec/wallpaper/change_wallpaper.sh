#!/bin/bash

feh --bg-scale "$1"
wal -i "$1"
truncate -s 0 ~/.config/bspwm/exec/wallpaper/current_wall
echo "$1" >> ~/.config/bspwm/exec/wallpaper/current_wall


sleep 1
cat ~/.cache/wal/colors-polybar.ini > ~/.config/bspwm/polybar/config/colors.ini

# Restart programs to change color scheme

#pkill dunst
#dunst&

~/.config/bspwm/polybar/launch.sh
