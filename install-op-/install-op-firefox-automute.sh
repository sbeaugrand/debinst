# ---------------------------------------------------------------------------- #
## \file install-op-firefox-automute.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=`ls -d $home/.mozilla/firefox/*.default*/extensions.json`
if [ -n "$file" ]; then
    if grep -q 'Auto mute' $file; then
        logWarn "auto-mute already exists"
        return 0
    fi
fi

if ! pgrep firefox >/dev/null; then
    sudo -u $user firefox &
    sleep 5
fi

sudo -u $user firefox\
 https://addons.mozilla.org/firefox/downloads/latest/auto-mute
