#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file run.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note docker build -t wine32 .
##       ./run.sh notepad
##       curl -O http://www.weberey.de/bin/gtt117.zip
##       mkdir gtt117
##       unzip gtt117.zip -d gtt117
##       ./run.sh gtt117/GTT.exe
# ---------------------------------------------------------------------------- #
if [ -f $1 ]; then
    cd `dirname $1`
    cmd=/tmp/pwd/`basename $1`
else
    cmd=$1
fi
shift

docker run -it\
 --rm\
 --hostname=$(hostname)\
 --env=DISPLAY\
 --volume=$HOME/.Xauthority:/root/.Xauthority:ro\
 --volume=/tmp/.X11-unix:/tmp/.X11-unix:ro\
 --volume=$PWD:/tmp/pwd\
 wine32 /usr/lib/wine/wine $cmd $*
