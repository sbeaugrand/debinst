# ---------------------------------------------------------------------------- #
## \file install-71-firefox.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ ! -d $home/.mozilla/firefox ]; then
    sudo -u $user firefox >>$log 2>&1 &
    sleep 10
    pid=`pgrep firefox`
    if [ -n "$pid" ]; then
        kill -15 $pid
    fi
fi

cwd=`pwd`
pushd $home/.mozilla/firefox/*.default || return 1
# Firefox telemetry and spy removal
# https://gist.github.com/MrYar
sed 's/US/FR/' $idir/install-*-firefox.js >user.js || return 1

file=$cwd/install-pr-firefox.html
if [ ! -f $file ]; then
    file=`ls $cwd/install*-71-firefox.html`
fi
if [ -n "$file" ]; then
    cat >>user.js <<EOF
user_pref("browser.startup.homepage", "file://$file");
EOF
fi

cat >>user.js <<EOF
user_pref("browser.urlbar.placeholderName", "Qwant");
user_pref("browser.download.dir", $home);
user_pref("browser.download.useDownloadDir", false);

// Vider l'historique lors de la fermeture
user_pref("privacy.sanitize.pending", "[{\"id\":\"shutdown\",\"itemsToClear\":[\"cache\",\"cookies\",\"history\",\"formdata\",\"downloads\",\"sessions\"],\"options\":{}}]");
user_pref("privacy.sanitize.sanitizeOnShutdown", true);

// lockPref

EOF
chown $user.$user user.js
popd
