#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file docker-xc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT=$1
shift
DIST=${DIST:-debian13}

test "$XC" != "aarch64-linux-gnu"   || ARCH=arm64
test "$XC" != "arm-linux-gnueabihf" || ARCH=armhf
echo "xc: ARCH=$ARCH"
echo "xc: DIST=$DIST"

if [ -n "$1" ]; then
    docker run -it --rm --volume=$PWD:/tmp/$PROJECT -w /tmp/$PROJECT\
     -e XC=$XC\
     -e DIST=$DIST\
     $DIST-$ARCH $*
else
    docker run -it --rm --volume=$PWD:/tmp/$PROJECT -w /tmp/$PROJECT\
     $DIST-$ARCH make xc XC=$XC CMAKE_OPT="\
      -DCMAKE_C_COMPILER=$XC-gcc\
      -DCMAKE_CXX_COMPILER=$XC-g++\
      -DDOCKER_XC=1"
fi
