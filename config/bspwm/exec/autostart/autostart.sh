picom --config ~/.config/picom/picom.conf &
export $(dbus-launch)
pgrep -x dunst > /dev/null || dunst &
libinput-gestures&
xrdb -merge ~/.Xresources &
bash ~/.config/bspwm/exec/wallpaper/random_wallpaper.sh
