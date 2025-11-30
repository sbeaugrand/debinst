# ---------------------------------------------------------------------------- #
## \file install-13-overlay.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/boot/armbianEnv.txt
[ -f $file ] || return 0

overlay=overlay-`grep BOARD= /etc/armbian-image-release | cut -d= -f2`
isFile $overlay.dts || return 0

if notGrep "$overlay" $file; then
    /usr/sbin/armbian-add-overlay $overlay.dts
    [ $? = 0 ] && logTodo "sudo reboot"
fi
