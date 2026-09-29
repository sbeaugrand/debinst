#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file docker-xp.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT=$1
BHOST=${DIST:-debian13}

test "$XC" != "aarch64-linux-gnu"   || ARCH=arm64
test "$XC" != "arm-linux-gnueabihf" || ARCH=armhf
echo "xp: ARCH=$ARCH"
echo "xp: DIST=$BHOST"

export DEBEMAIL=$DEBEMAIL
export DEBFULLNAME=$DEBFULLNAME
test -n "$DEBEMAIL"    || export DEBEMAIL=sbeaugrand@toto.fr
test -n "$DEBFULLNAME" || export DEBFULLNAME=sbeaugrand

VERSION=`head -n 1 debian/changelog | cut -d')' -f1 | cut -d'(' -f2`
BDIR=build-$XC
CONFIG_SITE=/etc/dpkg-cross/cross-config.$ARCH
OPTS=-a$ARCH
export DEB_BUILD_OPTIONS=nocheck
export XC=$XC
export XCVER=$XCVER
export XCDIR=$XCDIR
export CC=$XC-gcc
mkdir -p $BDIR/$PROJECT-$VERSION
cd $BDIR/$PROJECT-$VERSION || exit 1
rm -f debian/$PROJECT.install
dh_make --native --single --yes
rm -f debian/README*
test ! -d ../../debian || cp -Lr ../../debian/* debian/
test ! -d ../../debian-$BHOST || cp -Lr ../../debian-$BHOST/* debian/
find .. -maxdepth 1\
 -type f -executable -exec echo "{} /usr/bin/" >>debian/$PROJECT.install \;
SOURCE_DATE_EPOCH=`date +%s` dpkg-buildpackage --no-sign $OPTS
