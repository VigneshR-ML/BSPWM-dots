#!/usr/bin/env bash
#
# wifi.sh - Wi-Fi manager (nmcli + rofi)
#
# Shows the current connection, detected networks and power controls.
# Clicking a stored network connects instantly; unknown networks ask for a
# password. macOS-style: connection list + simple On/Off toggle.
#
set -euo pipefail

THEME="$HOME/.config/bspwm/rofi/wifi.rasi"

menu() { rofi -dmenu -p "Wi-Fi" -theme "$THEME"; }

wifi_on() { [ "$(nmcli radio wifi)" = "enabled" ]; }

connected_ssid() {
    nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}'
}

# Lines: "<SSID> <SECURITY>", prefixed with a signal icon.
# nmcli escapes literal colons inside SSIDs as `\:`, unescape for display.
network_lines() {
    nmcli -t -f IN-USE,SIGNAL,SSID,SECURITY dev wifi list --rescan yes 2>/dev/null |
    while IFS= read -r line; do
        inuse="$(printf '%s' "$line" | cut -d: -f1)"
        sig="$(printf '%s' "$line" | cut -d: -f2)"
        rest="$(printf '%s' "$line" | cut -d: -f3- | sed 's/\\:/:/g')"
        ssid="${rest%:*}"
        sec="${rest##*:}"

        case "$sig" in
            8[0-9] | 9[0-9]) icon="󰤨" ;;
            6[0-9] | 7[0-9]) icon="󰤥" ;;
            4[0-9] | 5[0-9]) icon="󰤢" ;;
            2[0-9] | 3[0-9]) icon="󰤟" ;;
            *) icon="󰤯" ;;
        esac
        [ "$inuse" = "yes" ] && icon="󰤨"

        printf '%s %s %s\n' "$icon" "$ssid" "$sec"
    done
}

connect() {
    local ssid="$1" pass
    if nmcli dev wifi connect "$ssid" >/dev/null 2>&1; then
        dunstify -r 7085 -u low "Wi-Fi" "Connected to $ssid"
        return 0
    fi
    pass="$(rofi -dmenu -p "Password for $ssid" -theme "$THEME")" || return 1
    [ -n "$pass" ] || return 1
    if nmcli dev wifi connect "$ssid" password "$pass" >/dev/null 2>&1; then
        dunstify -r 7085 -u low "Wi-Fi" "Connected to $ssid"
    else
        dunstify -r 7085 -u critical "Wi-Fi" "Connection to $ssid failed"
    fi
}

main() {
    local current toggle menu_list chosen
    current="$(connected_ssid || true)"

    if wifi_on; then
        toggle="󰖪  Turn Wi-Fi off"
    else
        toggle="󰖩  Turn Wi-Fi on"
    fi

    menu_list="$toggle"
    if [ -n "$current" ]; then
        menu_list="$menu_list
󱛇  Disconnect ($current)"
    fi
    if wifi_on; then
        menu_list="$menu_list
$(network_lines)"
    fi

    chosen="$(printf '%s\n' "$menu_list" | menu)" || exit 1
    chosen="${chosen#* }"   # strip the leading icon

    case "$chosen" in
        "Turn Wi-Fi off") nmcli radio wifi off ;;
        "Turn Wi-Fi on")  nmcli radio wifi on  ;;
        "Disconnect ("*) nmcli dev disconnect "$current" >/dev/null 2>&1 ;;
        *)
            # Network selected: `ssid security`, connect/disconnect by name
            ssid="${chosen% *}"
            if [ "$ssid" = "$current" ]; then
                nmcli dev disconnect "$current" >/dev/null 2>&1
            else
                connect "$ssid"
            fi
            ;;
    esac
}

main