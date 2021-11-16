# ---------------------------------------------------------------------------- #
## \file install-op-ssh-server.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if notFile /usr/sbin/sshd; then
    apt-get -y install openssh-server
fi

file=/etc/ssh/sshd_config
if notGrep '^PasswordAuthentication no' $file; then
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' $file
    /etc/init.d/ssh restart
fi
