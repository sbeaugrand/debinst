# ---------------------------------------------------------------------------- #
## \file install-op-mp3server-bin.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if notWhich mp3server; then
    pushd $idir/projects/mp3server || return 1
    sudo -u $user\
    make C=pi
    make C=pi user=$user install
    popd
fi

if systemctl -q is-enabled mp3server; then
    systemctl disable mp3server
fi

file=/etc/lirc/irexec.lircrc
if notGrep "toggle" $file; then
    cat >$file <<EOF
begin
    prog   = irexec
    button = KEY_PLAYPAUSE
   #config = sudo -u $user XMMS_PATH=unix:///run/xmms-ipc-ip /usr/bin/xmms2 toggle
    config = /usr/bin/mp3-toggle.sh
end
EOF
fi

dir=/mnt/mp3
if notDir $dir; then
    mkdir $dir
    chown $user:$user $dir
fi

file=/usr/bin/mp3-toggle.sh
if notFile $file; then
    sed "s/user=.*/user=$user/" mp3-op-toggle.sh >$file
    chmod 755 $file
fi

if ! systemctl -q is-enabled irexec 2>>$log; then
    systemctl enable irexec
fi
