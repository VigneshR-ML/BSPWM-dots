#!/usr/bin/env bash
#
# autostart.sh - session daemons for bspwm (Apple Silicon / Asahi Fedora)
#
# Called from bspwmrc. Everything here is idempotent so it is safe to run
# several times during one session.
#
set -euo pipefail

# D-Bus session bus (some tools need it even in Plain X).
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ] && command -v dbus-launch >/dev/null; then
    eval "$(dbus-launch --sh-syntax)"
fi

# Compositor: rounded corners, shadows, fade + window animations.
[ -z "${DISPLAY:-}" ] || {
    pgrep -x picom >/dev/null || picom --config "$HOME/.config/picom/picom.conf" &
}

# Notification daemon.
pgrep -x dunst >/dev/null || dunst &

# Wallpaper + pywal palette (picks a new random one every login).
bash "$HOME/.config/bspwm/scripts/wallpaper-random.sh" &

# Auto-lock on idle is intentionally DISABLED: DPMS blanking on the Apple
# panel hard-hangs the display on wake. Lock manually with Super+Shift+L
# (see ~/.config/bspwm/rofi/scripts/powermenu.sh "Lock").
true