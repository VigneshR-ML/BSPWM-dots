#!/usr/bin/env bash

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar left -c ~/.config/bspwm/polybar/config/config.ini &
polybar center -c ~/.config/bspwm/polybar/config/config.ini &
polybar right -c ~/.config/bspwm/polybar/config/config.ini &
