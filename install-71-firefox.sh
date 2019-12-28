# ---------------------------------------------------------------------------- #
## \file install-71-firefox.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ ! -d $home/.mozilla/firefox ]; then
    if [ -z "$DISPLAY" ]; then
        echo " warn: DISPLAY is not set" | tee -a $log
        return 0
    fi
    sudo -u $user firefox --headless >>$log 2>&1 &
    sleep 20
    pid=`pgrep firefox`
    if [ -n "$pid" ]; then
        kill -15 $pid
    fi
fi

pushd $home/.mozilla/firefox/*.default || return 1
# Firefox telemetry and spy removal
# https://gist.github.com/MrYar
sed 's/US/FR/' $idir/install-*-firefox.js >user.js || return 1

file=$idir/install-pr-firefox.html
if [ ! -f $file ]; then
    file=`ls $idir/install*-firefox.html`
fi
if [ -n "$file" ]; then
    cat >>user.js <<EOF
user_pref("browser.startup.homepage", "file://$file");
EOF
fi

cat >>user.js <<EOF
user_pref("browser.urlbar.placeholderName", "Google");
user_pref("browser.download.dir", "$home");
user_pref("browser.download.useDownloadDir", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.highlights", false);
user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.prerender", false);

// Vider l'historique lors de la fermeture
user_pref("privacy.sanitize.pending", "[{\"id\":\"shutdown\",\"itemsToClear\":[\"cache\",\"cookies\",\"offlineApps\",\"history\",\"formdata\",\"downloads\",\"sessions\",\"siteSettings\"],\"options\":{}}]");
user_pref("privacy.sanitize.sanitizeOnShutdown", true);

// lockPref

EOF
chown $user.$user user.js
popd

dir=`ls -d $home/.mozilla/firefox/*.default-esr`
if [ -n "$dir" ]; then
    pushd $dir || return 1
    cp -a ../*.default/user.js .
    popd
fi
