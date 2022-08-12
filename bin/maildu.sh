#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file maildu.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -n "$1" ]; then
    cd "$1"
else
    cd ~/Mail
fi
find . -type f -exec stat -c "%08s %n" {} \; | sort | tail -n 50 | cut -c12- |\
 sed "s/^\(.*\)$/stat --printf=\"%08s %n \" \1;\
 grep -m 1 --color '^Date: ' \1; grep -e 'filename=\"' -e '\tname=\"' \1/" | \
awk '{ system($0) }'
cd - >/dev/null
