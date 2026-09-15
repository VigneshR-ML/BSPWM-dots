#!/usr/bin/env bash
#
# powermenu.sh - system power menu (rofi)
#
# macOS-style shutdown/restart/lock/sleep/logout, with a yes/no confirmation
# for the destructive actions.
#
set -euo pipefail

THEME="$HOME/.config/bspwm/rofi/powermenu.rasi"
host="$(hostname)"
uptime_str="$(uptime -p | sed 's/^up //')"

menu() {
    rofi -dmenu -p "$host" -mesg "Uptime: $uptime_str" -theme "$THEME"
}

confirm() {
    printf 'Yes\nNo\n' |
        rofi -dmenu -p "Are you sure?" -theme-str 'listview {columns: 2; lines: 1;}' \
             -theme "$THEME"
}

lock_screen() {
    "$HOME/.config/bspwm/bin/lock.sh"
}

suspend() {
    playerctl -a pause 2>/dev/null || true
    pactl set-sink-mute @DEFAULT_SINK@ 1 2>/dev/null || true
    systemctl suspend
}

run() {
    local action="$1"
    case "$action" in
        Lock) lock_screen ;;
        Sleep) suspend ;;
        Logout)
            [ "$(confirm)" = "Yes" ] && bspc quit
            ;;
        Reboot)
            [ "$(confirm)" = "Yes" ] && systemctl reboot
            ;;
        "Shut Down")
            [ "$(confirm)" = "Yes" ] && systemctl poweroff
            ;;
    esac
}

main() {
    local options chosen
    options="󰌾  Lock
󰍃  Logout
  Sleep
󰜉  Reboot
⏻  Shut Down"

    chosen="$(printf '%s\n' "$options" | menu)" || exit 1
    run "${chosen#* }"
}

main