#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file replace.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ "$3" = "-n" ]; then
    grep --color=auto -rI --exclude-dir=build --exclude-dir=build-* --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.vagrant "$1"
    echo
    echo 'find . -type d \( -name build -o -name build-* -o -name .git -o -name .svn -o -name .vagrant \) -prune -o -type f -exec grep -qI "'$1'" {} \; -exec sed -i "s@'$1'@'$2'@g" {} \; -print'
    exit 0
fi
find . -type d \( -name build -o -name build-* -o -name .git -o -name .svn -o -name .vagrant \) -prune -o -type f -exec grep -qI "$1" {} \; -exec sed -i "s@$1@$2@g" {} \; -print
