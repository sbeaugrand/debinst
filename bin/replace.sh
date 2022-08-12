#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file replace.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ "$1" = "-n" ]; then
    shift
    echo 'find . -type d -name build -prune -o -type f -exec grep -qI "'$1'" {} \; -exec sed -i "s@'$1'@'$2'@g" {} \; -print'
    exit 0
fi
find . -type d -name build -prune -o -type f -exec grep -qI "$1" {} \; -exec sed -i "s@$1@$2@g" {} \; -print
