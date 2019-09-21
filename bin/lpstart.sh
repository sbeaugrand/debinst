#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file lpstart.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dev=`lpstat -d | grep "^system default destination:" | cut -d ' ' -f 4`
if [ -z "$dev" ]; then
    echo "todo: lpoption -d <dev>"
    exit 1
fi
echo "dev = $dev"
sudo /usr/sbin/lpadmin -p $dev -E
exit $?
