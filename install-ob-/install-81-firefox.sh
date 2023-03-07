# ---------------------------------------------------------------------------- #
## \file install-71-firefox.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ ! -d $home/.mozilla/firefox ]; then
    if [ -z "$DISPLAY" ]; then
        logError "DISPLAY is not set"
        return 0
    fi
    firefox --headless >>$log 2>&1 &
    sleep 20
    pid=`pgrep firefox`
    if [ -n "$pid" ]; then
        kill -15 $pid
    fi
fi

pushd $home/.mozilla/firefox/*.default || return 1
# Firefox telemetry and spy removal
download https://gist.github.com/MrYar/751e0e5f3f1430db7ec5a8c8aa237b72/raw/e95a7cdf37d8c8a57d1fc35cce750d6b85ee3d2f/_Firefox-88 || return 1
sed 's/US/FR/' $repo/_Firefox-88 >user.js || return 1
sed -i -e '/autofillForms/d' -e '/rememberSignons/d' -e '/showSearch/d' user.js
sed -i -e '/parent_directory/d' -e 's/)$/);/' user.js

file=$idir/install-ob-/install-*-firefox/homepage-pr-.html
if [ ! -f $file ]; then
    file=`ls $idir/install-ob-/install-*-firefox/homepage.html`
fi
if [ -n "$file" ]; then
    cat >>user.js <<EOF

user_pref("browser.startup.homepage", "file://$file");
EOF
fi

cat >>user.js <<EOF

user_pref("browser.compactmode.show", true);
user_pref("browser.uidensity", 1);
user_pref("browser.search.widget.inNavBar", true);
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

user_pref("privacy.sanitize.pending", "[{\"id\":\"shutdown\",\"itemsToClear\":[\"cache\",\"cookies\",\"history\",\"formdata\",\"downloads\",\"sessions\"],\"options\":{}},{\"id\":\"newtab-container\",\"itemsToClear\":[],\"options\":{}}]");
user_pref("privacy.sanitize.sanitizeOnShutdown", true);

EOF
file=`ls $idir/install-ob-/install-*-firefox/key4-pr-.db`
if notFile key4.db; then
    [ -n "$file" ] && cp $file key4.db
fi
file=`ls $idir/install-ob-/install-*-firefox/logins-pr-.json`
if notFile logins.json; then
    [ -n "$file" ] && cp $file logins.json
fi
popd

dir=`ls -d $home/.mozilla/firefox/*.default-esr`
if [ -n "$dir" ]; then
    pushd $dir || return 1
    cp -a ../*.default/user.js .
    if notFile key4.db; then
        cp -a ../*.default/key4.db .
    fi
    if notFile logins.json; then
        cp -a ../*.default/logins.json .
    fi
    popd
fi
