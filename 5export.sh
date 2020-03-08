# ---------------------------------------------------------------------------- #
## \file 5export.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$1" ]; then
    echo "Usage: `basename $0` <install-script.sh>"
    echo "Ex:    source <(`basename $0` <install-script.sh>)"
    exit 1
fi

#FIXME: wip
cat $1 |\
    sed 's/download  *\([^ ]*\)[^|]*/test -f \$file || curl -OL \1 /' |\
    sed 's/notDir/! test -d/g' |\
    sed 's/notFile/! test -f/g' |\
    sed 's/notGrep/! grep -q/g' |\
    sed 's/notLink/! test -L/g' |\
    sed 's#notWhich#! which >/dev/null#g' |\
    sed 's#\$repo/##g' |\
    sed 's/apt-get/sudo apt-get/g' |\
    sed 's/sudo -u \$user //g' |\
    sed '/chown/d' |\
cat
