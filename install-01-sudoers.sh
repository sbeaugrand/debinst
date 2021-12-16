# ---------------------------------------------------------------------------- #
## \file install-01-sudoers.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if notGrep "^$user ALL=(root) ALL" /etc/sudoers; then
    echo "Defaults rootpw" >>/etc/sudoers
    echo -e "$user ALL=(root) ALL" >>/etc/sudoers
fi
