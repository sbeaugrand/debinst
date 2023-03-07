# ---------------------------------------------------------------------------- #
## \file install-op-kivy.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if pip3 show -qq kivy; then
    pip3 uninstall kivy kivy-garden
fi
if isOnline; then
    pip3 install --no-binary kivy kivy
else
    if [ `uname -m` = "x86_64" ]; then
        dir="$idir/../wheels-amd64"
    else
        dir="$idir/../wheels-`uname -m`"
    fi
    pushd $dir || return 1
    pip3 install --no-binary kivy --no-index -f file://$dir Kivy-*.whl
    popd
fi
