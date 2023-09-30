# ---------------------------------------------------------------------------- #
## \file install-00-sudoers.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/etc/sudoers.d/$user

if notFile $file; then
    logInfo "add $file"
    su -c "echo '
Defaults rootpw
$user ALL=(root) ALL
$user ALL=($user) ALL
' >$file && chmod 440 $file"
fi
