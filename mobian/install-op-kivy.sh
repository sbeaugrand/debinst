# ---------------------------------------------------------------------------- #
## \file install-op-kivy.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note test with "fbcli -E alarm-clock-elapsed"
# ---------------------------------------------------------------------------- #
if ! pip3 show -qq Kivy; then
    sudo -u $user pip3 install kivy
fi
