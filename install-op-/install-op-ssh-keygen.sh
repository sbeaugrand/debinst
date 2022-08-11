# ---------------------------------------------------------------------------- #
## \file install-op-ssh-keygen.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$home/.ssh/id_rsa
if notFile $file; then
    sudo -u $user ssh-keygen -t rsa
fi
