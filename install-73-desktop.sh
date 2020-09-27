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

if notGrep "Default Applications" $file; then
    echo "[Default Applications]" >>$file
fi

if notGrep "image/jpeg=gpicview.desktop" $file; then
    echo "image/jpeg=gpicview.desktop" >>$file
fi

file=$home/.config/openbox/lxde-rc.xml

if notGrep 'key="Super_L"' $file; then
    sed -i 's/key="A-F1"/key="Super_L"/' $file
    openbox --reconfigure
fi
