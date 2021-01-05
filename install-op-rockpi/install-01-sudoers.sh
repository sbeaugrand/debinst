# ---------------------------------------------------------------------------- #
## \file install-01-sudoers.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/etc/sudoers.d/$user
if notFile $file; then
    cat >$file <<EOF
$user ALL=(root) NOPASSWD:/sbin/halt
$user ALL=(root) NOPASSWD:/usr/sbin/rtc
EOF
    chmod 440 $file
fi
