# ---------------------------------------------------------------------------- #
## \file install-op-mp3server-ro.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dest=/mnt/mp3
isDir $dest/mp3 || return 1

export XMMS_PATH=/run/xmms-ipc-ip
xmms2server="sudo --preserve-env=XMMS_PATH -u $user xmms2 server"

if notDir $home/.cache/xmms2; then
    sudo -u $user xmms2-launcher -i unix:///run/xmms-ipc-ip >>$log
    $xmms2server config >>$log
fi

file=$home/.cache/xmms2/xmms2d.log
if isFile $file && notLink $file; then
    $xmms2server shutdown
    mv $file $dest/
    ln -sf $dest/xmms2d.log $file
fi

file=$home/.config/xmms2/xmms2.conf
if isFile $file && notLink $file; then
    $xmms2server shutdown
    mv $file $dest/
    ln -sf $dest/xmms2d.log $file
fi

file=$home/.config/xmms2/medialib.db
if isFile $file; then
    $xmms2server shutdown
    mv $file $dest/
    $xmms2server config medialib.path $dest/medialib.db
fi
