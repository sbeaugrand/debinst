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
        echo " warn: adblockplus already exists" | tee -a $log
        return 0
    fi
fi

sudo -u $user firefox &
sleep 5
sudo -u $user firefox https://eyeo.to/adblockplus/firefox_install/
