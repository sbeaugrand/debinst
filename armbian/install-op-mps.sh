# ---------------------------------------------------------------------------- #
## \file install-op-mps.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/etc/lirc/irexec.lircrc
if notGrep "toggle" $file; then
    cat >$file <<EOF
begin
    prog   = irexec
    button = KEY_PLAYPAUSE
    config = /usr/bin/mps-toggle.sh
end
EOF
fi

dir=/mnt/mp3
if notDir $dir; then
    mkdir $dir
    chown $user:$user $dir
fi

file=/usr/bin/mps-toggle.sh
if notFile $file; then
    cp mps-pr-toggle.sh $file
fi

if ! systemctl -q is-enabled irexec 2>>$log; then
    systemctl enable irexec
fi
