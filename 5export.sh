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
    sed 's/download  *\([^ ]*\)[^|]*/test -f \$file || curl -O $file \1 /' |\
    sed 's/notDir/! test -d/' |\
    sed 's/notFile/! test -f/' |\
    sed 's/notGrep/! grep -q/' |\
    sed 's#notWhich#! which >/dev/null#' |\
    sed 's#\$repo/##' |\
    sed 's/apt-get/sudo apt-get/' |\
cat
