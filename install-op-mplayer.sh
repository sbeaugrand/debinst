# ---------------------------------------------------------------------------- #
## \file install-op-mplayer.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# sudo rm -fr ~/data/install-build/ffmpeg-4.1.6
# sudo rm -fr ~/data/install-build/mplayer-1.3.0
# sudo rm -f  ~/data/install-build/mplayer
# sudo rm -f /usr/local/bin/ffmpeg
# sudo rm -f /usr/local/bin/mplayer
# sudo rm -f /usr/local/bin/mencoder
# ---------------------------------------------------------------------------- #
mplayer=mplayer-1.3.0
ffmpeg=ffmpeg-4.1.6
codecs=essential-20071007

# ---------------------------------------------------------------------------- #
# sources
# ---------------------------------------------------------------------------- #
repoSav=$repo
source install-op-codecs.sh
source install-op-ffmpeg-src.sh
source install-op-mplayer-src.sh
repo=$repoSav

if notDir $bdir/$mplayer/ffmpeg; then
    cp -a $bdir/$ffmpeg $bdir/$mplayer/ffmpeg
    pushd $bdir || return 1
    if notLink mplayer || return 1; then
        ln -s $mplayer mplayer
    fi
    patch -p0 -i $idir/install-op-mplayer/mencoder_vol.patch >>$log 2>&1 ||\
      return 1
    patch -p0 -i $idir/install-op-mplayer/mencoder_lp.patch  >>$log 2>&1 ||\
      return 1
    popd
fi

# ---------------------------------------------------------------------------- #
# ffmpeg
# ---------------------------------------------------------------------------- #
if notFile /usr/local/bin/ffmpeg; then
    pushd $bdir/$mplayer
    ./configure --disable-ffmpeg_a >>$log 2>&1
    popd
    pushd $bdir/$mplayer/ffmpeg
    ./configure --enable-gpl --enable-libx264 --enable-libmp3lame --enable-libaom >>$log 2>&1
    make >>$log 2>&1
    make install >>$log 2>&1
    popd
fi

# ---------------------------------------------------------------------------- #
# mplayer
# ---------------------------------------------------------------------------- #
if notFile /usr/local/bin/mencoder; then
    pushd $bdir/$mplayer
    make >>$log 2>&1
    make install >>$log 2>&1
    popd
fi

# ---------------------------------------------------------------------------- #
# config
# ---------------------------------------------------------------------------- #
if notDir $home/.mplayer; then
    mkdir $home/.mplayer
fi

font=/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf
if notLink $home/.mplayer/subfont.ttf && isFile $font; then
    ln -s $font $home/.mplayer/subfont.ttf
fi

file=$home/.mplayer/config
if notFile $file || notGrep x11 $file; then
    cp install-op-mplayer/config $file
fi

chown -R $user.$user $home/.mplayer
