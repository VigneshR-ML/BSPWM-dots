#!/bin/sh
# ~/.xinitrc - plain-X X session (initiated with `startx`).

# HiDPI: 2x logical scale = 192 DPI. GDK/QT apps scale separately.
export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
export QT_SCALE_FACTOR=1.5

# User scripts (~/.local/bin) for the session environment.
export PATH="$HOME/.local/bin:$PATH"

# Apply X resources (DPI, fonts, cursor).
xrdb -merge "$HOME/.Xresources"

# Remap the Apple Cmd key(s) to Super_L (see ~/.Xmodmap).
xmodmap "$HOME/.Xmodmap" 2>/dev/null

# The window manager owns the rest (bspwmrc -> autostart.sh).
exec bspwm