# ---------------------------------------------------------------------------- #
## \file install-op-eeplot.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo
gitClone https://github.com/sbeaugrand/eeshow || return 1

if notWhich eeplot; then
    pushd $bdir/eeshow/eeshow || return 1
    make PREFIX=$home/.local >>$log 2>&1
    make PREFIX=$home/.local >>$log 2>&1 install
    popd
fi
