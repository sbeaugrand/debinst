# ---------------------------------------------------------------------------- #
## \file prepare.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
source install-op-codecs.sh
source install-op-ffmpeg-src.sh
source install-op-mplayer-src.sh
source install-14-cal.sh
source install-op-arduino.sh
source install-17-rdm.sh
source install-op-emacs-php.sh
source install-op-id3ed.sh
source install-op-mp3gain.sh
source install-op-sdcc-src.sh
source install-61-colorgcc.sh

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
