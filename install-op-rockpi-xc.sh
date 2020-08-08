# ---------------------------------------------------------------------------- #
## \file install-op-rockpi-xc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
CMAKE_OPT="
-DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc
-DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++
"
source projects/arm/mraa.sh
source install-op-rockpi/install-11-upm.sh
