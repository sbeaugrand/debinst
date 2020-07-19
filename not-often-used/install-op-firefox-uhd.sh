# ---------------------------------------------------------------------------- #
## \file install-op-firefox-uhd.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
pushd $home/.mozilla/firefox/*.default || return 1
if ! isFile user.js; then
    popd
    return 1
fi
cat >>user.js <<EOF
user_pref("layout.css.devPixelsPerPx", "1.9");

EOF
popd
