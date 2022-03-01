# ---------------------------------------------------------------------------- #
## \file install-01-sudoers.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/etc/sudoers.d/$user
if notFile $file; then
    cat >$file <<EOF
$user ALL=(root) NOPASSWD:/usr/sbin/tcps
$user ALL=(root) NOPASSWD:/usr/bin/nmcli c up
EOF
    chmod 440 $file
fi

file=/usr/sbin/tcps
if notFile $file; then
    cp tcps.sh $file
fi
