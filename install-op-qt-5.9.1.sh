# ---------------------------------------------------------------------------- #
## \file install-op-qt-5.9.1.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
vmm=5.9
vmmp=$vmm.1
file=qt-opensource-linux-x64-$vmmp.run

download http://download.qt.io/official_releases/qt/$vmm/$vmmp/$file || return 1

sudo -u $user $repo/$file\
 --no-force-installations\
 --script install-op-qt-$vmmp.qs\
 --platform minimal\
 --verbose\
 >>$log 2>&1
