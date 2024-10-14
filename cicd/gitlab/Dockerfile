# ---------------------------------------------------------------------------- #
## \file Dockerfile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
FROM debian:12

ADD libjsonrpccpp-client0_1.4.1-1.0_amd64.deb .
ADD libjsonrpccpp-common0_1.4.1-1.0_amd64.deb .
ADD libjsonrpccpp-server0_1.4.1-1.0_amd64.deb .
ADD libjsonrpccpp-stub0_1.4.1-1.0_amd64.deb .
ADD libjsonrpccpp-dev_1.4.1-1.0_amd64.deb .
ADD libmraa2_2.2.0-1_amd64.deb .
ADD libmraa-dev_2.2.0-1_amd64.deb .
ADD libupm-dev_2.0.0-1_amd64.deb .
ADD libupm-lcd2_2.0.0-1_amd64.deb .

RUN export DEBIAN_FRONTEND=noninteractive\
 && apt-get -y update\
 && apt-get -y install --no-install-recommends\
    build-essential\
    cmake\
    debhelper\
    lintian\
    libmpdclient-dev\
    liblirc-dev\
    ./*.deb
