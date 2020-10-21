# ---------------------------------------------------------------------------- #
## \file install-op-codecs.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
codecs=essential-20071007
file=$codecs.tar.bz2
repo=$idir/../repo

download http://www.mplayerhq.hu/MPlayer/releases/codecs/$file || return 1
untar $file || return 1

if notDir /usr/lib/codecs; then
    mkdir /usr/lib/codecs
    cp -a $bdir/$codecs/* /usr/lib/codecs/
fi
