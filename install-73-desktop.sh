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
