#!/usr/bin/env bash
#
# BSPWM-dots - one-shot setup for a fresh Fedora (Asahi / Workstation) system.
#
#   ./setup.sh
#
# What it does:
#   1. Installs every package this rice needs (dnf).
#   2. Installs pywal and libinput-gestures (not packaged in Fedora).
#   3. Copies the whole config tree into ~/.config.
#   4. Installs the dotfiles (.xinitrc, .xprofile, .Xresources, .Xmodmap).
#   5. Installs the bundled Nerd Fonts and sets wallpaper dir + screenshots dir.
#   6. Makes every helper script executable.
#
# Afterwards: reboot / log in on tty1 and run `startx`.
#
# Run as your normal user (sudo is prompted internally). On a brand new
# machine this is all you need.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEP=0

say() { printf '\n\033[1;32m[%02d]\033[0m %s\n' "$((++STEP))" "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }

# If run through sudo, resolve the real user home.
if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo root)}"
    REAL_HOME="$(eval echo "~$REAL_USER")"
    warn "Running as root; installing for user '$REAL_USER'."
else
    REAL_USER="$USER"
    REAL_HOME="$HOME"
fi

# ----------------------------------------------------------------------------
say "Checking Fedora / dnf"
# ----------------------------------------------------------------------------
if ! command -v dnf >/dev/null; then
    echo "This setup targets Fedora (dnf). Nothing was installed." >&2
    exit 1
fi

# ----------------------------------------------------------------------------
say "Installing Xorg + window manager + daemons"
# ----------------------------------------------------------------------------
sudo dnf install -y \
    xorg-x11-server-Xorg \
    xorg-x11-xinit \
    xorg-x11-xauth \
    xorg-x11-xkb-utils \
    xorg-x11-drv-libinput \
    xset xsetroot xrdb xmodmap xinput xrandr xev setxkbmap \
    dbus-x11 \
    bspwm sxhkd \
    polybar picom \
    rofi rofi-themes \
    dunst \
    i3lock xss-lock \
    feh ImageMagick \
    brightnessctl \
    Thunar \
    copyq

# ----------------------------------------------------------------------------
say "Installing audio / media / tools"
# ----------------------------------------------------------------------------
sudo dnf install -y \
    pipewire-pulseaudio wireplumber pulseaudio-utils \
    maim xclip playerctl \
    blueman bluez \
    NetworkManager \
    alacritty fish \
    libinput-utils \
    git curl unzip \
    adobe-source-han-sans-jp-fonts unifont-fonts

# ----------------------------------------------------------------------------
say "Installing pywal (not in Fedora repos) via pipx"
# ----------------------------------------------------------------------------
if ! command -v pipx >/dev/null; then
    sudo dnf install -y pipx python3-pip
fi
if ! command -v wal >/dev/null; then
    pipx install pywal || warn "pywal install failed - wallpaper color sync disabled"
fi

# ----------------------------------------------------------------------------
say "Installing libinput-gestures (not in Fedora repos)"
# ----------------------------------------------------------------------------
if ! command -v libinput-gestures >/dev/null; then
    tmp="$(mktemp -d)"
    git clone --depth 1 https://github.com/bulletmark/libinput-gestures "$tmp/libinput-gestures"
    sudo make -C "$tmp/libinput-gestures" install
    rm -rf "$tmp"
fi

# ----------------------------------------------------------------------------
say "Backing up any existing ~/.config"
# ----------------------------------------------------------------------------
if [ -d "$REAL_HOME/.config" ] && [ -n "$(ls -A "$REAL_HOME/.config" 2>/dev/null)" ]; then
    backup="$REAL_HOME/.config.backup-$(date +%Y%m%d-%H%M%S)"
    cp -a "$REAL_HOME/.config" "$backup"
    warn "Existing ~/.config backed up to $backup"
fi

# ----------------------------------------------------------------------------
say "Copying configuration tree into ~/.config"
# ----------------------------------------------------------------------------
mkdir -p "$REAL_HOME/.config"
cp -a "$REPO_DIR/config/." "$REAL_HOME/.config/"

# ----------------------------------------------------------------------------
say "Installing dotfiles"
# ----------------------------------------------------------------------------
install -m 644 "$REPO_DIR/xinitrc"   "$REAL_HOME/.xinitrc"
install -m 644 "$REPO_DIR/xprofile"  "$REAL_HOME/.xprofile"
install -m 644 "$REPO_DIR/Xresources" "$REAL_HOME/.Xresources"
install -m 644 "$REPO_DIR/Xmodmap"   "$REAL_HOME/.Xmodmap"

# ----------------------------------------------------------------------------
say "Installing Nerd Fonts (JetBrainsMono + Iosevka + Feather)"
# ----------------------------------------------------------------------------
mkdir -p "$REAL_HOME/.local/share/fonts"
cp -n "$REPO_DIR"/fonts/*.ttf "$REAL_HOME/.local/share/fonts/" || true
fc-cache -f >/dev/null 2>&1 || true

# ----------------------------------------------------------------------------
say "Setting up wallpaper + screenshots directories"
# ----------------------------------------------------------------------------
mkdir -p "$REAL_HOME/Pictures/Wallpaper" "$REAL_HOME/Pictures/Screenshots"
if [ -d "$REPO_DIR/Pictures/Wallpaper" ]; then
    cp -n "$REPO_DIR"/Pictures/Wallpaper/* "$REAL_HOME/Pictures/Wallpaper/" || true
fi

# ----------------------------------------------------------------------------
say "Making helper scripts executable"
# ----------------------------------------------------------------------------
chmod +x \
    "$REAL_HOME/.config/bspwm/bspwmrc" \
    "$REAL_HOME/.config/bspwm/bin/"*.sh \
    "$REAL_HOME/.config/bspwm/exec/autostart/autostart.sh" \
    "$REAL_HOME/.config/bspwm/exec/wallpaper/"*.sh \
    "$REAL_HOME/.config/bspwm/polybar/launch.sh" \
    "$REAL_HOME/.config/bspwm/rofi/scripts/"*.sh

# ----------------------------------------------------------------------------
say "Done"
# ----------------------------------------------------------------------------
cat <<EOF

Setup finished for user '$REAL_USER'.

  1) Log out / reboot.
  2) Log in on tty1.
  3) Run:  startx

  Notes:
   - Brightness keys  -> brightnessctl  (F1/F2)
   - Volume keys      -> pactl          (F11/F12)
   - Lock screen      -> Super+Shift+L
   - No auto-lock and no DPMS blanking: Apple Silicon screens hang on
     DPMS wake, so idle never blanks the display (see bspwmrc).
   - Wallpaper picker -> Super+W | random -> Super+Backslash | wifi -> Super+Shift+W
EOF