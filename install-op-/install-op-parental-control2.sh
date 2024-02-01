# ---------------------------------------------------------------------------- #
## \file install-op-parental-control2.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=$bdir/ctpar
if notDir $dir; then
    mkdir $dir
    cp $idir/install-op-/install-op-parental-control2/*.php $dir
fi

file=/etc/apache2/sites-enabled/ctpar.conf
if notFile $file; then
    sudoRoot cp $idir/install-op-/install-op-parental-control2/ctpar.conf $file
    sudoRoot systemctl restart apache2
fi

cat <<EOF

Todo:
adb install Kiwi\ Browser\ -\ Fast\ \&\ Quiet_120.0.6099.116_Apkpure.apk
adb shell "cd /storage/self/primary/Android/data && mkdir kiwi"
adb push ctpar.user.js manifest.json /storage/self/primary/Android/data/

EOF
