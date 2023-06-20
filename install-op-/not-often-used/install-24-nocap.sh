# ---------------------------------------------------------------------------- #
## \file install-24-nocap.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$home/.config/lxsession/LXDE/autostart
if notGrep nocap $file; then
    echo "@amixer -q set Capture nocap" >>$file
fi

file=$home/.config/openbox/lxde-rc.xml
if notGrep XF86AudioMicMute $file; then
    sed -i 's#</keyboard>#  <!-- Toggle audio capture -->\
  <keybind key="XF86AudioMicMute">\
    <action name="Execute"><command>amixer set Capture toggle</command></action>\
  </keybind>\
</keyboard>#' $file
fi
