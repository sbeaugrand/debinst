# ---------------------------------------------------------------------------- #
## \file 2simplecdd.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$2" ]; then
    echo -n "Usage: `basename $0`"
    echo " <simplecdd-...> <buildpackage-.../build>"
fi
simplecdd=$1
lpkg=$2

cd $simplecdd
make LPKG=../$lpkg
