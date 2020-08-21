# ---------------------------------------------------------------------------- #
## \file install-op-arduino.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
version=1.0.6
file=arduino-$version-linux64.tgz

repo=$idir/../repo
[ -d $repo ] || sudo -u $user mkdir $repo

download https://downloads.arduino.cc/$file || return 1
untar $file arduino-$version/arduino || return 1

gitClone https://github.com/SpenceKonde/ATTinyCore.git || return 1
