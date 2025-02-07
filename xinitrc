#merge xresorces
xrbd -merge ~/.Xresources

# Set DPI
export Xft.dpi=192

# Set GTK Scaling
export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
export QT_SCALE_FACTOR=1.5

#start WM
sxhkd &
exec bspwm
