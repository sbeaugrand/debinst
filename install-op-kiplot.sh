# ---------------------------------------------------------------------------- #
## \file install-op-kiplot.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo

gitClone https://github.com/sbeaugrand/kiplot.git || return 1

if ! isFile /usr/lib/python3/dist-packages/pcbnew.py; then
    cat <<EOF

Try :
sudo vi /etc/apt/sources.list.d/debian.list
deb http://httpredir.debian.org/debian buster-backports main contrib non-free
deb http://httpredir.debian.org/debian buster-backports-sloppy main contrib non-free
sudo apt update
sudo apt -t buster-backports install kicad

EOF
    return 1
fi

if notWhich kiplot; then
    pushd $bdir/kiplot || return 1
    pip3 install -e . >>$log 2>&1
    popd
fi

#FIXME: workaround for ghostscript version 9.53.3
file=/usr/bin/ps2epsi.ps
if notLink $file; then
    ln -s /usr/share/ghostscript/*/lib/ps2epsi.ps $file
fi
