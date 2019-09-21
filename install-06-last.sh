# ---------------------------------------------------------------------------- #
## \file install-06-last.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ ! -f /var/log/wtmp ]; then
    touch /var/log/wtmp
fi
