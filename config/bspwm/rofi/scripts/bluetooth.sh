#!/usr/bin/env bash
#
# bluetooth.sh - Bluetooth manager (bluetoothctl + rofi)
#
# macOS-style: a simple device list with connect/disconnect, plus a power
# toggle and scan control in the header.
#
# Usage:
#   bluetooth.sh            show the main device menu
#   bluetooth.sh --status   print a short status line (for polybar)
#
set -euo pipefail

THEME="$HOME/.config/bspwm/rofi/bluetooth.rasi"

menu() { rofi -dmenu -p "Bluetooth" -theme "$THEME"; }

power() { bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2}'; }
scanning() { bluetoothctl show 2>/dev/null | awk '/Discovering:/{print $2}'; }

is_connected() { bluetoothctl info "$1" 2>/dev/null | grep -q "Connected: yes"; }
is_trusted()   { bluetoothctl info "$1" 2>/dev/null | grep -q "Trusted: yes"; }

# "MAC-ADDRESS alias" lines for paired/known devices
known_device_lines() {
    bluetoothctl devices | awk '{addr=$2; $1=$2=""; sub(/^  */,""); print addr "\t" $0}'
}

device_address() {
    # turn an "alias" menu choice back into a MAC by matching the known list
    local want="$1" addr alias found=""
    while IFS=$'\t' read -r addr alias; do
        if [ "$alias" = "$want" ]; then found="$addr"; break; fi
    done < <(known_device_lines)
    printf '%s' "$found"
}

toggle_power() {
    if [ "$(power)" = "yes" ]; then
        bluetoothctl power off
    else
        if [ ! -e /dev/rfkill ] || rfkill list bluetooth 2>/dev/null | grep -qi 'blocked: yes'; then
            rfkill unblock bluetooth 2>/dev/null     # macOS-style "kill switch" OFF
        fi
        bluetoothctl power on
    fi
}

toggle_scan() {
    if [ "$(scanning)" = "yes" ]; then
        bluetoothctl scan off 2>/dev/null || pkill -f "bluetoothctl scan" 2>/dev/null
    else
        bluetoothctl scan on &
        sleep 5
    fi
}

device_menu() {
    local mac="$1" alias="$2" options chosen
    # Establish the alias through bluetoothctl in case it was entered by name
    [ -n "$mac" ] || return 0

    options=""
    if is_connected "$mac"; then options="$options\n󰂯 Disconnect"; else options="$options\n󰂯 Connect"; fi
    if is_trusted "$mac"; then options="$options\n󰂲 Untrust";     else options="$options\n󰂲 Trust";     fi
    options="$options\n󰇘 Back"

    chosen="$(printf '%b\n' "$options" | menu)" || return 0
    case "$chosen" in
        *Connect*)    bluetoothctl connect "$mac" ;;
        *Disconnect*) bluetoothctl disconnect "$mac" ;;
        *Untrust*)    bluetoothctl untrust "$mac" ;;
        *Trust*)      bluetoothctl trust "$mac" ;;
    esac
}

main_menu() {
    local header devices chosen dev_addr
    if [ "$(power)" = "yes" ]; then
        header="󰂲  Power: On"
        [ "$(scanning)" = "yes" ] && header="󰂲  Power: On (scanning)"
        header="$header\n󰂯  Toggle scan"
    else
        header="󰂲  Power: Off"
    fi
    devices="$(known_device_lines | cut -f2)"

    chosen="$(printf '%b\n%s\n' "$header" "$devices" | menu)" || return 0
    case "$chosen" in
        "Power: On" | "Power: On (scanning)" | "Power: Off")
            toggle_power
            ;;
        "Toggle scan")
            toggle_scan
            ;;
        *)
            dev_addr="$(device_address "$chosen")"
            [ -n "$dev_addr" ] && device_menu "$dev_addr" "$chosen"
            ;;
    esac
}

main() {
    case "${1:-}" in
        --status)
            if [ "$(power)" = "yes" ]; then echo "󰂯"
            else echo "󰂲"; fi
            ;;
        *) main_menu ;;
    esac
}

main "$@"