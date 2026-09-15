# BSPWM-dots

Minimal, fast bspwm rice for Fedora / Arch Linux on a Mac (Apple Silicon, Asahi)
or any X11 laptop.

![stack](https://img.shields.io/badge/WM-bspwm-2f3c3d?style=flat-square)

## Stack

| Piece        | Tool                   |
|--------------|------------------------|
| Window manager | [bspwm](https://github.com/baskerville/bspwm) |
| Hotkeys        | [sxhkd](https://github.com/baskerville/sxhkd) |
| Bar            | [polybar](https://github.com/polybar/polybar) |
| Compositor     | [picom](https://github.com/yshui/picom) with fade/slide animations |
| Notifications  | [dunst](https://github.com/dunst-project/dunst) |
| Launcher/menus | [rofi](https://github.com/davatorium/rofi) |
| Terminal       | [alacritty](https://github.com/alacritty/alacritty) |
| Clipboard      | [copyq](https://github.com/hluk/CopyQ) |
| Wallpapers     | [feh](https://feh.finalrewind.org/) + [pywal](https://github.com/dylanaraps/pywal) |
| Gestures       | libinput-gestures |
| Fonts          | JetBrainsMono Nerd Font, Iosevka Nerd Font, Feather |

Runs on Xorg via `startx`, no display manager.

## Install (fresh Fedora)

```sh
git clone https://github.com/VigneshR-ML/BSPWM-dots.git
cd BSPWM-dots
./setup.sh
```

That installs every package (dnf), pywal (pipx) and libinput-gestures
(GitHub), copies the configs/dotfiles/fonts/wallpapers, then you just:

```
reboot   # or log out
startx   # on tty1
```

Run `setup.sh` as a normal user — sudo is prompted internally.

## Manual install (any distro)

Copy the pieces yourself:

```sh
cp -r config/.           ~/.config/
cp xinitrc xprofile Xresources Xmodmap ~/
cp -n fonts/*.ttf        ~/.local/share/fonts/
fc-cache -f
cp -n Pictures/Wallpaper/* ~/Pictures/Wallpaper/
chmod +x ~/.config/bspwm/bin/*.sh \
         ~/.config/bspwm/exec/**/*.sh \
         ~/.config/bspwm/polybar/launch.sh \
         ~/.config/bspwm/rofi/scripts/*.sh
```

Required packages (dnf names): `bspwm sxhkd polybar picom rofi dunst feh
ImageMagick i3lock xss-lock brightnessctl copyq Thunar maim xclip playerctl
alacritty fish pipewire-pulseaudio wireplumber pulseaudio-utils blueman
libinput-gestures` plus the `xorg-x11-*` basics.

## Keybindings

| Keys | Action |
|------|--------|
| `Super + Return` | Terminal (alacritty) |
| `Super + D` | App launcher (rofi drun) |
| `Super + P` | Power menu (shutdown/reboot/suspend/lock/logout) |
| `Super + W` / `Super + Shift + W` | Wallpaper picker / Wi-Fi menu |
| `Super + B` | Bluetooth menu |
| `Super + Shift + L` | Lock screen |
| `Super + Space` | Keyboard layout (US/RU) |
| `Super + Y` | Screenshot (full / `+Shift` area, `+Ctrl` save) |
| `Super + V` | Clipboard (copyq) |
| `Super + {H,J,K,L}` | Focus direction |
| `Super + Shift + {H,J,K,L}` | Move window |
| `Super + Alt + {H,J,K,L}` | Resize window |
| `Super + M` | Toggle tiled/monocle |
| `Super + Shift + X` | Kill window |
| `Super + Alt + Q` / `R` | Quit / restart bspwm |
| `Super + {1-0}` | Workspaces 1-10, `Super + Alt + {1-0}` for 11-20 |
| `XF86AudioRaise/Lower/Mute` | Volume |
| `XF86MonBrightnessUp/Down` | Brightness |

## Notes & platform quirks

- **No DPMS blanking / auto-lock.** On Apple Silicon (Asahi) the panel hangs
  when waking from DPMS off, freezing the whole session. The idle path is
  therefore disabled (`xset s off -dpms` in `bspwmrc`, no `xss-lock`).
  Lock on demand with `Super + Shift + L`.
- `localhost` timers in polybar are per-machine; `xset s off -dpms` is safe
  everywhere.
- Runs 10 desktops (I-X) on one monitor; add `bspc monitor -d` lines if you
  plug in external displays.