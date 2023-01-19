# ---------------------------------------------------------------------------- #
## \file install-op-kivy.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if sudo -u $user pip3 show -qq kivy; then
    sudo -u $user pip3 uninstall kivy
fi
sudo -u $user pip3 install --no-binary kivy kivy
