# ---------------------------------------------------------------------------- #
## \file install-op-megapixels.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Workaround for damaged touchscreen on the bottom
# ---------------------------------------------------------------------------- #
gitClone https://gitlab.com/postmarketOS/megapixels.git || return 1

if notFile /usr/local/bin/megapixels; then
    pushd $bdir/megapixels || return 1
    git apply $idir/mobian/touchscreen/install-op-megapixels.patch || return 1
    meson . build
    ninja -C build
    ninja -C build install
    popd
fi
