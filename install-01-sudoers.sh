# ---------------------------------------------------------------------------- #
## \file install-01-sudoers.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if notGrep "^$user ALL=(root) ALL" /etc/sudoers; then
    echo "Defaults rootpw" >>/etc/sudoers
    echo -e "$user ALL=(root) ALL" >>/etc/sudoers
fi

if notGrep cryptsetup /etc/sudoers; then
cat >>/etc/sudoers <<EOF
$user ALL=(root) NOPASSWD:/sbin/true
$user ALL=(root) NOPASSWD:/sbin/modprobe dm-crypt
$user ALL=(root) NOPASSWD:/sbin/cryptsetup
$user ALL=(root) NOPASSWD:/sbin/dd
$user ALL=(root) NOPASSWD:/sbin/mount
$user ALL=(root) NOPASSWD:/sbin/umount
$user ALL=(mutt) ALL
mutt ALL=(root) ALL
EOF
fi

[ -x /sbin/true   ] || cp -u `which true`   /sbin/
[ -x /sbin/dd     ] || cp -u `which dd`     /sbin/
[ -x /sbin/mount  ] || cp -u `which mount`  /sbin/
[ -x /sbin/umount ] || cp -u `which umount` /sbin/
