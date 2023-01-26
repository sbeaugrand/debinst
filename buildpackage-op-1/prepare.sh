# ---------------------------------------------------------------------------- #
## \file prepare.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
source install-op-/install-op-codecs.sh || return 1
source install-op-/install-op-ffmpeg-src.sh || return 1
source install-op-/install-op-mplayer-src.sh || return 1
source install-op-/install-op-arduino.sh || return 1
source install-op-/install-op-id3ed.sh || return 1
source install-op-/install-op-mp3gain.sh || return 1
source install-ob-/install-61-colorgcc.sh || return 1
source install-op-/install-op-fonts-morse.sh || return 1
source install-op-/install-op-eeplot.sh || return 1
source install-op-/install-op-kiplot.sh || return 1
source latex/cal.sh || return 1
source latex/rdm.sh || return 1
source projects/avr/avrusb.sh || return 1
source projects/avr/usbtinyisp/usbtinyisp.sh || return 1
source armbian/install-10-WiringPi.sh || return 1
source install-op-/install-op-m4acut.sh || return 1
source install-op-/install-op-diffchar.sh || return 1
source install-op-/install-op-imscripts.sh || return 1
source install-op-/install-op-avidemux.sh || return 1
source install-op-/install-op-camotics.sh || return 1
source hardware/install-op-grbl-sim.sh || return 1
source hardware/marlin/install-op-marlin-src.sh || return 1
# source hardware/install-op-lp-hpP1006.sh
# source hardware/install-op-scan-mustekA3.sh

# source projects/arm/mraa.sh
# source armbian/install-11-mraa.sh
# source armbian/install-12-upm.sh
source install-op-/install-op-mraa-xc.sh || return 1

# wheels
for args in\
 bezier\
 "--no-binary kivy kivy"\
 pybluez\
 pydbus\
 buildozer\
 cython\
 pymeeus\
 solidpython\
; do
    downloadWheel "$args"
done

# libdvdcss
/usr/lib/libdvd-pkg/b-i_libdvdcss.sh
file=`ls -1 -rt /usr/src/libdvd-pkg/*.bz2 | tail -n 1`
if [ -z "$file" ]; then
    logError "/usr/src/libdvd-pkg/*.bz2 not found"
    return 1
fi
repo=$idir/../repo
mkdir -p $repo
cp -au $file $repo
