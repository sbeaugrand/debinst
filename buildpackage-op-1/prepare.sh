# ---------------------------------------------------------------------------- #
## \file prepare.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
source install-op-codecs.sh || return 1
source install-op-ffmpeg-src.sh || return 1
source install-op-mplayer-src.sh || return 1
source install-op-arduino.sh || return 1
source install-op-emacs-php.sh || return 1
source install-op-id3ed.sh || return 1
source install-op-mp3gain.sh || return 1
source install-op-sdcc-src.sh || return 1
source install-61-colorgcc.sh || return 1
source install-op-fonts-morse.sh || return 1
source install-op-eeplot.sh || return 1
source install-op-kiplot.sh || return 1
source latex/cal.sh || return 1
source latex/rdm.sh || return 1
source projects/avr/avrusb.sh || return 1
source projects/avr/usbtinyisp/usbtinyisp.sh || return 1
source armbian/install-10-WiringPi.sh || return 1
source install-op-m4acut.sh || return 1
source install-op-diffchar.sh || return 1
source install-op-imscripts.sh || return 1

# source projects/arm/mraa.sh
# source armbian/install-11-mraa.sh
# source armbian/install-12-upm.sh
source install-op-mraa-xc.sh || return 1

# libdvdcss
/usr/lib/libdvd-pkg/b-i_libdvdcss.sh
file=`ls -1 -rt /usr/src/libdvd-pkg/*.bz2 | tail -n 1`
if [ -z "$file" ]; then
    echo " error: /usr/src/libdvd-pkg/*.bz2 not found" | tee -a $log
    return 1
fi
repo=$idir/../libdvdcss
mkdir -p $repo
cp -au $file $repo
