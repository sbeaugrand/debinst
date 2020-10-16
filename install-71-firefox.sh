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
download https://gist.github.com/MrYar/751e0e5f3f1430db7ec5a8c8aa237b72/raw/6dba4f0d5eccac8691ad0b6b7f82287accaa719a/_Firefox-79 || return 1
sed 's/US/FR/' $repo/_Firefox-79 >user.js || return 1
sed -i -e '/autofillForms/d' -e '/rememberSignons/d' -e '/showSearch/d' user.js

file=$idir/install-*-firefox/homepage-pr-.html
if [ ! -f $file ]; then
    file=`ls $idir/install-*-firefox/homepage.html`
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

user_pref("signon.autofillForms", true);
user_pref("signon.rememberSignons", true);
user_pref("browser.contentblocking.category", "custom");
user_pref("network.cookie.cookieBehavior", 1);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);
user_pref("network.cookie.lifetimePolicy", 2);
user_pref("accessibility.force_disabled", 1);

// lockPref

EOF
chown $user.$user user.js
file=`ls $idir/install-*-firefox/key4-pr-.db`
if notFile key4.db; then
    [ -n $file ] && sudo -u $user cp $file key4.db
fi
file=`ls $idir/install-*-firefox/logins-pr-.json`
if notFile logins.json; then
    [ -n $file ] && sudo -u $user cp $file logins.json
fi
popd

dir=`ls -d $home/.mozilla/firefox/*.default-esr`
if [ -n "$dir" ]; then
    pushd $dir || return 1
    sudo -u $user cp -a ../*.default/user.js .
    if notFile key4.db; then
        sudo -u $user cp -a ../*.default/key4.db .
    fi
    if notFile logins.json; then
        sudo -u $user cp -a ../*.default/logins.json .
    fi
    popd
fi
