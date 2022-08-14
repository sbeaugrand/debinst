# ---------------------------------------------------------------------------- #
## \file install-op-backports.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
sta=`lsb_release -sc`

file=/etc/apt/sources.list.d/backports.list
if notFile $file; then
    cat >$tmpf <<EOF
deb http://httpredir.debian.org/debian $sta-backports main contrib non-free
deb http://httpredir.debian.org/debian $sta-backports-sloppy main contrib non-free
# ex: sudo apt -t $sta-backports install kicad
EOF
    sudoRoot cp $tmpf $file
fi
