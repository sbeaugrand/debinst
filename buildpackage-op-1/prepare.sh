# ---------------------------------------------------------------------------- #
## \file prepare.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
source hardware/install-op-pc-a0.sh

sourceList "
install-op-/install-op-codecs.sh
install-op-/install-op-ffmpeg-src.sh
install-op-/install-op-mplayer-src.sh
#hardware/install-op-lp-hpP1006.sh
#hardware/install-op-scan-mustekA3.sh
"

# wheels
echo "wheels"
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
