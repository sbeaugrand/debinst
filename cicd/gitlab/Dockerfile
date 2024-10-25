# ---------------------------------------------------------------------------- #
## \file Dockerfile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
FROM debian:12

ADD libjsonrpccpp-client0_1.4.1-1.0_armhf.deb /sbuild/
ADD libjsonrpccpp-common0_1.4.1-1.0_armhf.deb /sbuild/
ADD libjsonrpccpp-server0_1.4.1-1.0_armhf.deb /sbuild/
ADD libjsonrpccpp-stub0_1.4.1-1.0_armhf.deb /sbuild/
ADD libjsonrpccpp-dev_1.4.1-1.0_armhf.deb /sbuild/
ADD libmraa2_2.2.0-1_armhf.deb /sbuild/
ADD libmraa-dev_2.2.0-1_armhf.deb /sbuild/
ADD libupm-dev_2.0.0-1_armhf.deb /sbuild/
ADD libupm-lcd2_2.0.0-1_armhf.deb /sbuild/

COPY stable-armhf.tar.xz /sbuild/
COPY stable-armhf-f.conf /etc/schroot/chroot.d/

RUN export DEBIAN_FRONTEND=noninteractive\
 && apt-get -y update\
 && apt-get -y install --no-install-recommends\
    debhelper\
    lintian

RUN export DEBIAN_FRONTEND=noninteractive\
 && apt-get -y install --no-install-recommends\
    sbuild\
    binfmt-support\
    qemu-user-static\
    fakeroot\
    schroot
