# ---------------------------------------------------------------------------- #
## \file install-op-meteo.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$home/.config/lxpanel/LXDE/panels/panel

if ! isFile $file; then
    cp /etc/xdg/lxpanel/default/panels/panel $file
    chown $user.$user $file
fi
if ! isFile $bdir/panel; then
    cp $file $bdir/panel
fi

if notGrep weather $file; then
    cat >>$file <<EOF
Plugin {
  type=weather
  Config {
    alias=Rambouillet
    city=Rambouillet
    state=Ile-de-France
    country=France
    woeid="618766"
    units=c
    interval=15
    enabled=1
  }
}
EOF
    lxpanelctl restart
fi
