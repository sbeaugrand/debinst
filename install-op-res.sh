# ---------------------------------------------------------------------------- #
## \file install-op-res.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# gtf 1600 900 60
# ---------------------------------------------------------------------------- #
output=${OUTPUT:-VGA-1}

if [ -z "$DISPLAY" ]; then
    echo " warn: DISPLAY is not set" | tee -a $log
    return 0
fi

dxres=`xrdb -symbols | grep DX_RES | cut -d '=' -f 2`
if ((dxres < 1920)); then
    echo " warn: DX_RESOLUTION=$dxres" | tee -a $log
    return 0
fi

if ! xrandr | grep $output | grep -q 1600x900; then
xrandr --newmode "1600x900_60.00"\
 119.00 1600 1696 1864 2128 900 901 904 932 -hsync +vsync
xrandr --addmode $output 1600x900_60.00
xrandr --output $output --mode 1600x900_60.00
else
    echo " warn: mode 1600x900 already set" | tee -a $log
fi

file=/etc/X11/Xsession.d/45x11-xrandr
if notFile $file; then
    cat >>$file <<EOF
xrandr --newmode "1600x900_60.00"\
 119.00 1600 1696 1864 2128 900 901 904 932 -hsync +vsync
xrandr --addmode $output 1600x900_60.00
EOF
fi
