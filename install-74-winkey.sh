# ---------------------------------------------------------------------------- #
## \file install-74-winkey.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$home/.config/openbox/lxde-rc.xml

if notGrep 'key="Super_L"' $file; then
    sed -i 's/key="A-F1"/key="Super_L"/' $file
    openbox --reconfigure
fi
