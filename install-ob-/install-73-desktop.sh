# ---------------------------------------------------------------------------- #
## \file install-73-desktop.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$home/.config/mimeapps.list

addmimeapps()
{
    if notGrep "$1" $file; then
        echo "$1" >>$file
    fi
}
if notGrep "Default Applications" $file; then
    echo "[Default Applications]" >>$file
fi
addmimeapps "image/jpeg=gpicview.desktop;"
addmimeapps "image/png=gpicview.desktop;"
addmimeapps "application/pdf=org.gnome.Evince.desktop;"
addmimeapps "message/rfc822=emacs.desktop;"
addmimeapps "text/plain=mousepad.desktop;"
