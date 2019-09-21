# ---------------------------------------------------------------------------- #
## \file install-op-autologin.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/etc/lightdm/lightdm.conf

if notGrep "^autologin-user=$user" $file; then
    sed -i.bak "s/#autologin-user=.*/autologin-user=$user/" $file
fi
