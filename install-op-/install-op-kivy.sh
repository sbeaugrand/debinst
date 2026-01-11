# ---------------------------------------------------------------------------- #
## \file install-op-kivy.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir="$idir/../wheels-`uname -m`"
pushd $dir || return 1
if ! ls Kivy-*.whl >/dev/null; then
    pip wheel --no-binary kivy kivy
fi
pip install --no-binary kivy --no-index -f file://$dir Kivy-*.whl
popd
