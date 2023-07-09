# ---------------------------------------------------------------------------- #
## \file install-op-mplayer.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
codecs=essential-20071007

if [ "$args" = "-r" ]; then
    cat <<EOF

rm -fr ~/data/install-build/ffmpeg-\
`grep -m 1 version install-op-/install-op-ffmpeg-src.sh | cut -d '=' -f 2`
rm -fr ~/data/install-build/mplayer-\
`grep -m 1 version install-op-/install-op-mplayer-src.sh | cut -d '=' -f 2`
rm -f  ~/data/install-build/mplayer
rm -f ~/.local/bin/ffmpeg
rm -f ~/.local/bin/ffprobe
rm -f ~/.local/bin/ffplay
rm -f ~/.local/bin/mplayer
rm -f ~/.local/bin/mencoder

EOF
    return 0
fi

# ---------------------------------------------------------------------------- #
# sources
# ---------------------------------------------------------------------------- #
repoSav=$repo
source install-op-/install-op-codecs.sh
source install-op-/install-op-ffmpeg-src.sh
source install-op-/install-op-mplayer-src.sh
repo=$repoSav

if notDir $bdir/$mplayer/ffmpeg; then
    cp -a $bdir/$ffmpeg $bdir/$mplayer/ffmpeg
    pushd $bdir || return 1
    if notLink mplayer || return 1; then
        ln -s $mplayer mplayer
    fi
    patch -p0 -i $idir/install-op-/install-op-mplayer/mencoder_vol.patch\
     >>$log 2>&1 || return 1
    patch -p0 -i $idir/install-op-/install-op-mplayer/mencoder_lp.patch\
     >>$log 2>&1 || return 1
    if notGrep "libaom" mplayer/etc/codecs.conf; then
        patch -p0 -i $idir/install-op-/install-op-mplayer/codecs.patch\
         >>$log 2>&1 || return 1
    fi
    popd
fi

# ---------------------------------------------------------------------------- #
# ffmpeg
# ---------------------------------------------------------------------------- #
if notFile $home/.local/bin/ffmpeg; then
    pushd $bdir/$mplayer/ffmpeg
    ./configure --prefix=$home/.local --enable-gpl --enable-libx264\
     --enable-libmp3lame --enable-libaom --enable-libvorbis >>$log 2>&1
    make >>$log 2>&1
    make >>$log 2>&1 install
    popd
fi

# ---------------------------------------------------------------------------- #
# mplayer
# ---------------------------------------------------------------------------- #
if notFile $home/.local/bin/mencoder; then
    pushd $bdir/$mplayer
    ./configure --prefix=$home/.local --disable-ffmpeg_a --enable-ffmpeg_so\
     --extra-libs="-L$home/.local/lib -lavdevice -lavfilter -lavformat -lavcodec -lpostproc -lswresample -lswscale -lavutil -laom -lvorbisenc -llzma" >>$log 2>&1
    make >>$log 2>&1
    make >>$log 2>&1 install
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
    cp install-op-/install-op-mplayer/config $file
fi
