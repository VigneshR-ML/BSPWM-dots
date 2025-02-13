#!/usr/bin/bash

send_notif() {
    dunstctl close-all

    # Get the default sink (audio output)
    sink=$(pactl get-default-sink)

    # Get the volume level
    volume=$(pactl get-sink-volume "$sink" | awk '{print $5}' | tr -d '%')

    # Get the mute status
    muted=$(pactl get-sink-mute "$sink" | awk '{print $2}')

    # Select volume icon based on volume level
    if [ "$muted" = "yes" ]; then
        icon="󰖁 "  # Muted icon
        volume="Muted"
    elif [ "$volume" -le 33 ]; then
        icon="󰕿 "  # Low volume
    elif [ "$volume" -le 66 ]; then
        icon="󰖀 "  # Medium volume
    else
        icon="󰕾 "  # High volume
    fi

    # Send notification with icon
    dunstify -h int:value:"$volume" "$icon Volume: $volume%" -t 1000
}

# Execute accordingly
case "$1" in
    "--inc")
        pactl set-sink-volume @DEFAULT_SINK@ +1%
        send_notif
        ;;
    "--dec")
        pactl set-sink-volume @DEFAULT_SINK@ -1%
        send_notif
        ;;
    *)
        send_notif
        ;;
esac
