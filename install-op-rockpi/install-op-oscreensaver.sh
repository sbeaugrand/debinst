# ---------------------------------------------------------------------------- #
## \file install-op-oscreensaver.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/usr/bin/oscreensaver
if notFile $file; then
    pushd ../projects/mp3server || return 1
    make -f oscreensaver.mk || return 1
    make -f oscreensaver.mk reinstall || return 1
    popd
fi

if ! systemctl -q is-enabled oscreensaver 2>>$log; then
    pushd ../projects/mp3server || return 1
    make -f oscreensaver.mk install
    popd
fi
