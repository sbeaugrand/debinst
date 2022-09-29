# ---------------------------------------------------------------------------- #
## \file install-op-firefox-cookies.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note https://addons.mozilla.org/fr/firefox/addon/i-dont-care-about-cookies/
# ---------------------------------------------------------------------------- #
file=`ls -d $home/.mozilla/firefox/*.default*/extensions.json`
if [ -n "$file" ]; then
    if grep -q 't care about cookies' $file; then
        logWarn "i-dont-care-about-cookies already exists"
        return 0
    fi
fi

if ! pgrep firefox >/dev/null; then
    sudo -u $user firefox &
    sleep 5
fi

sudo -u $user firefox\
 https://addons.mozilla.org/firefox/downloads/latest/i-dont-care-about-cookies
