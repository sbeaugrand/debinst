# ---------------------------------------------------------------------------- #
## \file install-op-scangearmp2.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
cat >/usr/share/applications/scangearmp2.desktop <<EOF
[Desktop Entry]
Name=scangearmp2
Comment=Scan
Exec=scangearmp2
Icon=applications-other
Terminal=false
Type=Application
Categories=Graphics;
EOF
