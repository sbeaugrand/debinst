FROM debian:trixie-slim

RUN apt-get update\
 && apt-get -y install\
 scons\
 build-essential\
 libqt5websockets5-dev\
 libqt5opengl5-dev\
 libnode-dev\
 libglu1-mesa-dev\
 pkgconf\
 git\
 python3-six\
 python3-setuptools\
 qttools5-dev-tools\
 && git clone https://github.com/CauldronDevelopmentLLC/cbang\
 && git clone https://github.com/CauldronDevelopmentLLC/CAMotics\
 && scons -C cbang v8_compress_pointers=false\
 && export CBANG_HOME=$PWD/cbang\
 && cd CAMotics\
 && sed -i 's/libssl1.1/libssl3/' SConstruct\
 && scons\
 && scons package
