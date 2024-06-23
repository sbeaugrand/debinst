#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file mpg2avi.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Example :
##       ln -s vlc.avi record.mpg
##       vf=crop=360:360:1000:100 mpg2avi.sh record.mpg
# ---------------------------------------------------------------------------- #
vbitrate=900
abitrate=128
lavcopts="
vcodec=mpeg4:vbitrate=$vbitrate:vhq:v4mv:trell:vqmin=2:
o=luma_elim_threshold=-4:
o=chroma_elim_threshold=9:lumi_mask=0.05:dark_mask=0.01"
vfilters=${vf:-pp=fd,scale=720:400}
src="$1"
dst="${1%.*}.avi"

encode()
{
    pass=$1
    aq=$2
    mencoder "$src"\
     -ovc lavc    -lavcopts vpass=$pass:$lavcopts\
     -oac mp3lame -lameopts cbr:br=$abitrate:aq=$aq\
     -ffourcc DIVX\
     -vf $vfilters\
     -o "$dst"
}

encode 1 9
encode 2 0
