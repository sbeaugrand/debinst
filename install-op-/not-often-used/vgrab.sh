#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file vgrab.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
sw=1280
sh=720
if [ "$1" = "-f" ]; then
    sw=`xrdb -symbols | grep DWIDTH | cut -d '=' -f 2`
    sh=`xrdb -symbols | grep DHEIGHT | cut -d '=' -f 2`
    shift
fi
if [ -n "$1" ]; then
    vc=$1
else
    vc=grab.mkv
fi
fx=`xrdb -query | grep "xterm\*font" | awk -F "\t|x" '{ print $3 }'`
fy=`xrdb -query | grep "xterm\*font" | awk -F "\t|x" '{ print $4 }'`
xterm -geometry $(($sw/$fx-2))x$(($sh/$fy-2))+0+0 -e "screen -m -S vc bash" &
sleep 1
screen -S vc -X screen
echo
echo -n "ffmpeg -s ${sw}x$sh -r 25 -f x11grab -i :0.0"
echo " -c:v libx264 -qp 0 -preset ultrafast $vc"
echo
echo "press q [enter] to quit"
read ret
while [ "$ret" != q ]; do
    read ret
done
screen -S vc -X quit
echo
echo "ffmpeg -i $vc -s ${sw}x$sh -c:v libx264 -preset veryslow v$vc"
echo
