# ---------------------------------------------------------------------------- #
## \file install-op-parental-control2.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$bdir/ctpar/log.php
if notFile $file; then
    cp $idir/install-op-/install-op-parental-control2/log.php $file
fi

file=/etc/apache2/sites-enabled/ctpar.conf
if notFile $file; then
    sudoRoot cp $idir/install-op-/install-op-parental-control2/ctpar.conf $file
    sudoRoot systemctl restart apache2
fi

cat <<EOF

Todo:
adb install Kiwi\ Browser\ -\ Fast\ \&\ Quiet_120.0.6099.116_Apkpure.apk
adb shell "cd /storage/self/primary/Android/data && mkdir com.github.kiwibrowser"
adb push kiwictp.user.js manifest.json /storage/self/primary/Android/data/com.github.kiwibrowser/
adb shell pm list packages
adb shell pm uninstall --user 0 com.android.chrome
adb shell pm uninstall --user 0 com.sec.android.app.sbrowser

adb shell pm uninstall --user 0 com.samsung.android.scloud
adb shell pm uninstall --user 0 com.samsung.android.spay
adb shell pm uninstall --user 0 com.google.android.gms
EOF
