# ---------------------------------------------------------------------------- #
## \file install-op-kiplot.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../kiplot
[ -d $repo ] || sudo -u $user mkdir $repo

gitClone https://github.com/johnbeard/kiplot.git || return 1

isFile /usr/lib/python3/dist-packages/pcbnew.py || return 1

if notWhich kiplot; then
    pushd $bdir/kiplot || return 1
    pip3 install -e . >>$log 2>&1
    popd
fi
