# ---------------------------------------------------------------------------- #
## \file install-op-kiplot.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo

gitClone https://github.com/parogers/gsim.git || return 1

if notWhich gsim; then
    pushd $bdir/gsim || return 1
    pip3 install -e . >>$log 2>&1
    popd
fi
