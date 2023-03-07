# ---------------------------------------------------------------------------- #
## \file install-op-mraa-xc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
CMAKE_OPT="
-DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc
-DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++
-DBUILDSWIG=OFF
"
source armbian/install-11-mraa.sh

CMAKE_OPT="
-DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc
-DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++
"
source armbian/install-12-upm.sh
