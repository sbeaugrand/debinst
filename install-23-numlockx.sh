# ---------------------------------------------------------------------------- #
## \file install-23-numlockx.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$home/.config/lxsession/LXDE/autostart

if notGrep numlockx $file; then
    echo "@/usr/bin/numlockx on" >>$file
fi
