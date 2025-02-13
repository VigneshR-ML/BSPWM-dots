#!/usr/bin/bash

send_notif(){
    dunstctl close-all

    brightness=$(brightnessctl g)
    max_brightness=$(brightnessctl m)
    brightness=$(( brightness * 100 / max_brightness ))
    if [ "$brightness" -le 25 ]; then
        icon="󰃞 "  # Low brightness
    elif [ "$brightness" -le 50 ]; then
        icon="󰃝 "  # Medium-low brightness
    elif [ "$brightness" -le 75 ]; then
        icon="󰃟 "  # Medium-high brightness
    else
        icon="󰃠 "  # High brightness
    fi
    dunstify -h int:value:$brightness "$icon Brightness: $brightness%" -t 1000
}

# Execute accordingly
case "$1" in
        "--inc")
                brightnessctl s +10%
                ;;
        "--dec")
                brightnessctl s 10%-
                ;;
        *)
                send_notif
                ;;
esac

send_notif
