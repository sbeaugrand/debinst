# ---------------------------------------------------------------------------- #
## \file install-op-volet.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=../install-14-cal
file=build/sun
if notFile $dir/$file; then
    pushd $dir || return 1
    mkdir -p build
    make $file >>$log
    popd
fi

if notFile /etc/init.d/voletd; then
    pushd install-op-volet || return 1
    make install
    popd
fi
