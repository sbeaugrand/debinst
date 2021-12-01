# ---------------------------------------------------------------------------- #
## \file install-73-desktop.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$home/.config/pcmanfm/LXDE/desktop-items-0.conf

if notGrep "show_trash=0" $file; then
    sed -i 's/show_trash=.*/show_trash=0/' $file
fi

if notGrep "desktop_font=Sans 7" $file; then
    sed -i 's/desktop_font=.*/desktop_font=Sans 7/' $file
fi

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
addmimeapps "image/jpeg=gpicview.desktop"
addmimeapps "image/png=gpicview.desktop;"
addmimeapps "application/pdf=org.gnome.Evince.desktop;"
addmimeapps "message/rfc822=emacs.desktop;"

file=$home/.config/openbox/lxde-rc.xml

if notGrep 'key="Super_L"' $file; then
    sed -i 's/key="A-F1"/key="Super_L"/' $file
    openbox --reconfigure
fi

if notGrep ">screen<" $file; then
    sed -i 's#</keyboard>#  <!-- Terminal -->\
  <keybind key="C-A-t">\
    <action name="Execute"><command>lxterminal</command></action>\
  </keybind>\
</keyboard>#' $file
    openbox --reconfigure
fi
