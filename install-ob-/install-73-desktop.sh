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
addmimeapps "image/jpeg=gpicview.desktop;"
addmimeapps "image/png=gpicview.desktop;"
addmimeapps "application/pdf=org.gnome.Evince.desktop;"
addmimeapps "message/rfc822=emacs.desktop;"
addmimeapps "text/plain=mousepad.desktop;"

file=$home/.config/openbox/lxde-rc.xml

if notGrep 'key="Super_L"' $file; then
    sed -i 's/key="A-F1"/key="Super_L"/' $file
    openbox --reconfigure
fi

if notGrep "C-A-l" $file; then
    sed -i 's#</keyboard>#  <!-- Lock screen -->\
  <keybind key="C-A-l">\
    <action name="Execute"><command>xscreensaver-command -lock</command></action>\
  </keybind>\
</keyboard>#' $file
    openbox --reconfigure
fi

if notGrep "C-A-t" $file; then
    sed -i 's#</keyboard>#  <!-- Terminal -->\
  <keybind key="C-A-t">\
    <action name="Execute"><command>xterm -T mxterm</command></action>\
  </keybind>\
</keyboard>#' $file
    openbox --reconfigure
fi

if notGrep 'title="mxterm"' $file; then
    sed -i 's#</applications>#  <application title="mxterm">\
    <maximized>yes</maximized>\
  </application>\
</applications>#' $file
    openbox --reconfigure
fi

if notGrep "C-A-BackSpace" $file; then
    sed -i 's#</keyboard>#  <!-- Restart X Window server -->\
  <keybind key="C-A-BackSpace">\
    <action name="Execute"><command>sudo systemctl restart lightdm</command></action>\
  </keybind>\
</keyboard>#' $file
    openbox --reconfigure
fi
