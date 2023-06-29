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
addmimeapps "application/pdf=org.gnome.Evince.desktop;"
addmimeapps "application/x-shellscript=mousepad.desktop;"
addmimeapps "audio/mpeg=vlc.desktop;"
addmimeapps "audio/x-wav=vlc.desktop;"
addmimeapps "image/jpeg=gpicview.desktop;"
addmimeapps "image/png=gpicview.desktop;"
addmimeapps "message/rfc822=emacs.desktop;"
addmimeapps "text/plain=mousepad.desktop;"
addmimeapps "text/x-python=mousepad.desktop;"
addmimeapps "video/mp4=vlc.desktop;"
addmimeapps "video/mpeg=vlc.desktop;"
addmimeapps "video/webm=vlc.desktop;"
addmimeapps "video/x-matroska=vlc.desktop;"
