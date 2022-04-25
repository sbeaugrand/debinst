# ---------------------------------------------------------------------------- #
## \file install-01-sudoers.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/etc/sudoers.d/$user

if notFile $file; then
    echo " info: add to sudoers: $user ALL=(root) ALL"
    su -c "echo -e 'Defaults rootpw\n$user ALL=(root) ALL\n$user ALL=($user) ALL' >$file && chmod 440 $file"
fi
