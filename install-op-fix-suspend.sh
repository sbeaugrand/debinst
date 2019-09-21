# ---------------------------------------------------------------------------- #
## \file install-op-fix-suspend.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/etc/systemd/logind.conf
if grep -q suspend $file; then
    sed -i.bak 's/#\(.*\)=suspend/\1=ignore/' $file
fi
