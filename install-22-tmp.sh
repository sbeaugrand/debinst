# ---------------------------------------------------------------------------- #
## \file install-22-tmp.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/usr/lib/tmpfiles.d/tmp.conf

if isFile $file || return 1; then
    if grep -q "d /tmp" $file; then
        sudoRoot sed -i "'s@d /tmp@D /tmp@'" $file
    fi
fi
