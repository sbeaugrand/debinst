# ---------------------------------------------------------------------------- #
## \file usbtinyisp.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
repo=$idir/../repo
[ -d $repo ] || sudo -u $user mkdir $repo

url=http://learn.adafruit.com/system/assets/assets/000/010/327/original
file=usbtiny_v2.0_firm.zip
download $url/$file usbtinyisp.zip || return 1
untar usbtinyisp.zip || return 1
