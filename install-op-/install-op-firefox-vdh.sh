# ---------------------------------------------------------------------------- #
## \file install-op-firefox-vdh.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note https://addons.mozilla.org/en-US/firefox/addon/video-downloadhelper/
# ---------------------------------------------------------------------------- #
file=addon-3006-latest.xpi
url=https://addons.mozilla.org/firefox/downloads/latest/video-downloadhelper

download $url/$file || return 1

json=`ls -d $home/.mozilla/firefox/*.default*/extensions.json`
if [ -n "$json" ]; then
    if grep -q 'Video DownloadHelper' $json; then
        logWarn "video-downloadhelper already exists"
        return 0
    fi
fi

if ! pgrep firefox >/dev/null; then
    firefox &
    sleep 5
fi

firefox $repo/$file
