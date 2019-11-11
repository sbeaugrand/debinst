# ---------------------------------------------------------------------------- #
## \file install-op-mp3server-ro.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dest=/mnt/mp3
isDir $dest/mp3 || return 1

export XMMS_PATH=/run/xmms-ipc-ip
xmms2server="sudo --preserve-env=XMMS_PATH -u pi xmms2 server"

# fake-hwclock
file=/etc/fake-hwclock.data
if isFile $file && notLink $file; then
    mv $file $dest/
    ln -sf $dest/fake-hwclock.data $file
fi
fake-hwclock save

# ntp
file=/var/lib/ntp/ntp.drift
if isFile $file && notLink $file; then
    mv $file $dest/
    ln -sf $dest/ntp.drift $file
fi

# xmms
if notDir /home/pi/.cache/xmms2; then
    sudo -u pi xmms2-launcher -i unix:///run/xmms-ipc-ip >>$log
    $xmms2server config >>$log
fi

file=/home/pi/.cache/xmms2/xmms2d.log
if isFile $file && notLink $file; then
    $xmms2server shutdown
    mv $file $dest/
    ln -sf $dest/xmms2d.log $file
fi

file=/home/pi/.config/xmms2/medialib.db
if isFile $file; then
    $xmms2server shutdown
    mv $file $dest/
    $xmms2server config medialib.path $dest/medialib.db
fi
