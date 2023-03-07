# ---------------------------------------------------------------------------- #
## \file install-op-firefox-abp.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note https://adblockplus.org/
# ---------------------------------------------------------------------------- #
file=`ls -d $home/.mozilla/firefox/*.default*/extensions.json`
if [ -n "$file" ]; then
    if grep -q 'Adblock Plus' $file; then
        logWarn "adblockplus already exists"
        return 0
    fi
fi

if ! pgrep firefox >/dev/null; then
    firefox &
    sleep 5
fi

firefox https://eyeo.to/adblockplus/firefox_install/
