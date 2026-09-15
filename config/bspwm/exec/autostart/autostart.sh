picom --config ~/.config/picom/picom.conf &
export $(dbus-launch)
pgrep -x dunst > /dev/null || dunst &
bash ~/.config/bspwm/exec/wallpaper/random_wallpaper.sh &

# Auto-lock on idle disabled: DPMS blanking on the Apple panel hangs the screen
# (lock manually from sxhkd instead)
