# ---------------------------------------------------------------------------- #
## \file install-07-panel.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$home/.config/lxpanel/LXDE/panels/panel

if notFile $file; then
    cp /etc/xdg/lxpanel/default/panels/panel $file
    chown $user.$user $file
fi
if notFile $bdir/panel; then
    cp $file $bdir/panel
fi

addButton()
{
    app=$1
    if grep -q "$app" $file; then
        echo " warn: $app already in $file" | tee -a $log
        return 0
    fi
    cp $file $bdir/panel.bak
    cat $bdir/panel.bak |\
        tr '\n' '@' |\
sed "s/Button/Button {@            id=$app.desktop@        }@        Button/" |\
        tr '@' '\n' >$file
    chown $user.$user $file
    rm $bdir/panel.bak
    return 0
}
addButton thunar
addButton emacs
addButton firefox-esr
addButton screen

delPattern()
{
    pattern=$1
    if ! grep -q "$pattern" $file; then
        echo " warn: $pattern not in $file" | tee -a $log
        return 0
    fi
    cp $file $bdir/panel.bak
    cat $bdir/panel.bak |\
        sed "/$pattern/D" |\
        tr '\n' '@' |\
        sed "s/@  *Button {@  *}//g" |\
        sed "s/@  *Config {@  *}//g" |\
        sed "s/@  *Plugin {@  *}//g" |\
        tr '@' '\n' >$file
    chown $user.$user $file
    rm $bdir/panel.bak
    return 0
}
delPattern pcmanfm
delPattern lxde-x-terminal-emulator
delPattern lxde-x-www-browser
delPattern space
delPattern Size
delPattern Button1
delPattern Button2
delPattern wincmd

if notGrep batt $file; then
    if upower -e | grep -q battery; then
        cat >>$file <<EOF
Plugin {
  type=batt
  Config {
  }
}
EOF
    fi
fi

if ! grep -q "autohide" $file; then
    sed -i 's/height=\(.*\)/height=\1\n    autohide=1/' $file
elif grep -q "autohide=0" $file; then
    sed -i 's/autohide=0/autohide=1/' $file
else
    echo " warn: autohide=1 already in $file" | tee -a $log
fi

if ! grep -q "ShowAllDesks" $file; then
    cp $file $bdir/panel.bak
    cat $bdir/panel.bak |\
        tr '\n' '@' |\
        sed "s/\(type=taskbar@  Config {\)/\1@    ShowAllDesks=0/" |\
        tr '@' '\n' >$file
    chown $user.$user $file
    rm $bdir/panel.bak
elif grep -q "ShowAllDesks=1" $file; then
    sed -i 's/ShowAllDesks=1/ShowAllDesks=0/' $file
fi

lxpanelctl restart
