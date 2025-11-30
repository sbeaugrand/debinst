# ---------------------------------------------------------------------------- #
## \file install-op-volume.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ `grep BOARD= /etc/armbian-image-release | cut -d= -f2` = "rockpi-s" ]; then
    amixer -q set 'DAC LINEOUT Right' 100% unmute
    amixer -q set 'DAC LINEOUT Left' 100% unmute
else
    amixer -q set 'Line Out' 94% unmute
    amixer -q set 'DAC' 98% unmute
fi
/sbin/alsactl store
