#!/usr/bin/env bash
#
# launch.sh - start (or restart) the polybar bars
#
set -euo pipefail

CONFIG="$HOME/.config/bspwm/polybar/config/config.ini"

LOG="${XDG_RUNTIME_DIR:-/tmp}/polybar.log"
: >"$LOG"

killall -q polybar 2>/dev/null || true
while pgrep -x polybar >/dev/null; do sleep 0.3; done

nohup polybar left  -c "$CONFIG" >>"$LOG" 2>&1 &
nohup polybar right -c "$CONFIG" >>"$LOG" 2>&1 &

sleep 1
if ! pgrep -x polybar >/dev/null; then
    echo "polybar failed to start (see ~/.config/bspwm/polybar/config/config.ini)" >&2
    exit 1
fi