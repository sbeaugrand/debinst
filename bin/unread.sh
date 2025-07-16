#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file unread.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if ! which newsboat >/dev/null; then
    exit 0
fi
count=`newsboat -x reload -x print-unread`
if echo $count | grep -qv '^0 '; then
    notify-send -t 0 "newsboat" "$count"
fi
