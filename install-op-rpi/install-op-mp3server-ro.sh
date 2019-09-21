# ---------------------------------------------------------------------------- #
## \file install-op-mp3server-ro.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dest=/mnt/mp3

isDir $dest || return 1

# fake-hwclock
file=/etc/fake-hwclock.data
if isFile $file && notLink $file; then
    mv $file $dest/
    ln -sf $dest/fake-hwclock.data $file
fi
fake-hwclock save

# ntp
file=/var/lib/ntp/ntp.drift
if isFile $file notLink $file; then
    mv $file $dest/
    ln -sf $dest/ntp.drift $file
fi

# xmms
if notDir /home/pi/.cache/xmms2; then
    sudo -u $user xmms2 server config >>$log
fi

file=/home/pi/.cache/xmms2/xmms2d.log
if isFile $file && notLink $file; then
    sudo -u $user xmms2 server shutdown
    mv $file $dest/
    ln -sf $dest/xmms2d.log $file
fi

file=/home/pi/.config/xmms2/medialib.db
if isFile $file; then
    sudo -u $user xmms2 server shutdown
    mv $file $dest/
    sudo -u pi xmms2 server config medialib.path $dest/medialib.db
fi
