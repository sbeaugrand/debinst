# ---------------------------------------------------------------------------- #
## \file install-op-firefox-automute.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=`ls -d $home/.mozilla/firefox/*.default*/extensions.json`
if [ -n "$file" ]; then
    if grep -q 'Auto mute' $file; then
        echo " warn: auto-mute already exists" | tee -a $log
        return 0
    fi
fi

sudo -u $user firefox https://addons.mozilla.org/firefox/downloads/latest/auto-mute
