# ---------------------------------------------------------------------------- #
## \file Dockerfile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
FROM debian:12

RUN export DEBIAN_FRONTEND=noninteractive\
 && apt-get -y update\
 && apt-get -y install --no-install-recommends\
    debhelper\
    cppcheck\
    uncrustify\
    lintian\
    git\
    curl\
    unzip\
    sbuild\
    binfmt-support\
    qemu-user-static\
    fakeroot\
    schroot

COPY stable-arm*.tar.xz /sbuild/
COPY stable-arm*-f.conf /etc/schroot/chroot.d/

COPY libjsonrpccpp-client0_1.4.1-1.0_arm*.deb /sbuild/
COPY libjsonrpccpp-common0_1.4.1-1.0_arm*.deb /sbuild/
COPY libjsonrpccpp-server0_1.4.1-1.0_arm*.deb /sbuild/
COPY libjsonrpccpp-stub0_1.4.1-1.0_arm*.deb /sbuild/
COPY libjsonrpccpp-dev_1.4.1-1.0_arm*.deb /sbuild/
COPY libmraa2_2.2.0-1_arm*.deb /sbuild/
COPY libmraa-dev_2.2.0-1_arm*.deb /sbuild/
COPY libupm-dev_2.0.0-1_arm*.deb /sbuild/
COPY libupm-lcd2_2.0.0-1_arm*.deb /sbuild/

COPY uncrustify.sh /usr/bin/
COPY uncrustify.cfg /root/.uncrustify.cfg
