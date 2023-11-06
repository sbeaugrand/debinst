# ---------------------------------------------------------------------------- #
## \file install-op-transcode.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
mirror=https://distfiles.gentoo.org/distfiles
transcode=transcode-1.1.7
patch=$transcode-ffmpeg4.patch.xz
subtitleripper=subtitleripper-0.3-4

download $mirror/06/$transcode.tar.bz2 || return 1
untar $transcode.tar.bz2 || return 1

download $mirror/17/$patch || return 1

if notFile $bdir/$transcode/import/tcextract; then
    pushd $bdir/$transcode
    unxz -cd $repo/$patch | patch -p1 >>$log 2>&1
    ./configure --disable-libjpeg >>$log 2>&1
    make >>$log 2>&1
    popd
    pushd $bdir || return 1
    chown -R $user:$user $transcode
    popd
fi

download $mirror/b7/$subtitleripper.tgz || return 1
untar $subtitleripper.tgz subtitleripper/vobsub.c || return 1

if notDir $bdir/$transcode/contrib/subrip; then
    mkdir $bdir/$transcode/contrib
    mkdir $bdir/$transcode/contrib/subrip
    pushd $bdir/$transcode/contrib/subrip || return 1
    cp $bdir/subtitleripper/* .
    popd
fi

if notFile $bdir/$transcode/contrib/subrip/srttool; then
    pushd $bdir/$transcode/contrib/subrip || return 1
    sed -i.bak 's/getline/get_line/' vobsub.c
    sed -i.bak 's/-lppm/-lnetpbm/' Makefile
    make >>$log 2>&1
    popd
    pushd $bdir || return 1
    chown -R $user:$user $transcode
    popd
fi
