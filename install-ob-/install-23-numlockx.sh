# ---------------------------------------------------------------------------- #
## \file install-23-numlockx.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$home/.config/lxsession/LXDE/autostart

if notGrep numlockx $file; then
    if [ -z "$DISPLAY" ]; then
        logError "DISPLAY is not set"
        return 0
    fi
    echo "@/usr/bin/numlockx on" >>$file
fi

if ! numlockx status | grep -q on; then
    numlockx on
fi
