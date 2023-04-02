# ---------------------------------------------------------------------------- #
## \file install-op-fonts-gcodefonts.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
pyver=`python3 -c '
import sys
print("{}.{}".format(sys.version_info.major, sys.version_info.minor))'`

file=$home/.local/lib/python$pyver/site-packages/gcodefonts.egg-link
if notFile $file; then
    pushd $idir/latex/gcodefonts || return 1
    make install
    popd
fi
