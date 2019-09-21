# ---------------------------------------------------------------------------- #
## \file install-70-wallpaper.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
mode=stretch
mode=fit

if [ -z "$width" ]; then
    width=`xrdb -symbols | grep DWIDTH | cut -d '=' -f 2`
fi
if [ -z "$height" ]; then
    height=`xrdb -symbols | grep DHEIGHT | cut -d '=' -f 2`
fi

if ((3440 * $height == 1440 * $width)); then
    w=3440
    h=1440
elif ((4096 * $height == 2160 * $width)); then
    w=4096
    h=2160
elif ((3840 * $height == 2160 * $width)); then
    w=3840
    h=2160
elif ((2560 * $height == 1600 * $width)); then
    w=2560
    h=1600
elif ((2048 * $height == 1536 * $width)); then
    w=2048
    h=1536
elif ((2560 * $height == 2048 * $width)); then
    w=2560
    h=2048
else
    w=$width
    h=$height
fi

file=`ls install-*-wallpaper/*-${w}x${h}.png 2>/dev/null | tail -n 1`
if [ -z "$file" ]; then
    file=`ls install-*-wallpaper/build/*-${w}x${h}.png 2>/dev/null`
fi

if [ -z "$file" ]; then
    sudo -u $user mkdir -p `ls -d install-*-wallpaper`/build
    name=$bdir/fractal-${w}x${h}
    spanX=5E-04
    spanY=`echo $spanX | awk '{ printf "%E",$1 * '$h' / '$w' }'`
    cat >$name.config <<EOF
c075
mandelbrot
-1.005E-01 -8.4006E-01 $spanX $spanY
1000 1000
1
0x0
iterationcount
smooth
loglog
0.45 0.2
0 0x39a0 0.25 0xffffff 0.5 0xfffe43 0.75 0xbf0800 1 0x39a0
EOF
    fractalnow -c $name.config -x $w -y $h -o $bdir/fractal.png >>$log
    convert $bdir/fractal.png\
      -fill blue -opaque black\
      -modulate 50,25,50\
      -flop\
      $name.png
    mv $name.png install-*-wallpaper/build/
fi

file=`ls install-*-wallpaper/*-${width}x${height}.png 2>/dev/null | tail -n 1`
if [ -z "$file" ]; then
    file=`ls install-*-wallpaper/build/*-${width}x${height}.png 2>/dev/null`
fi

if [ -z "$file" ]; then
    convert install-*-wallpaper/build/fractal-${w}x${h}.png\
      -resize ${width}x${height}\
      $bdir/fractal-${width}x${height}.png
    mv $bdir/fractal-${width}x${height}.png install-*-wallpaper/build/
    file=`ls install-*-wallpaper/build/*-${width}x${height}.png 2>/dev/null`
fi

su -c "pcmanfm --set-wallpaper=$idir/$file --wallpaper-mode=$mode" $user
