# ---------------------------------------------------------------------------- #
## \file install-op-kitris.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo
gitClone https://github.com/sbeaugrand/kitris.git || return 1

file=$home/.local/share/applications/kitris.desktop
if notFile $file; then
    pushd $bdir/kitris || return 1
    make desktop
    popd
fi
