# ---------------------------------------------------------------------------- #
## \file install-op-ssh-server.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if notFile /usr/sbin/sshd; then
    sudoRoot apt-get -y install openssh-server
fi

file=/etc/ssh/sshd_config
if notGrep '^PasswordAuthentication no' $file; then
    sudoRoot sed -i "'s/#PasswordAuthentication yes/PasswordAuthentication no/'" $file
    sudoRoot /etc/init.d/ssh restart
fi

file=$home/.ssh/authorized_keys
if notFile $file; then
    cp install-pr-/install-pr-authorized_keys $file
fi
