# ---------------------------------------------------------------------------- #
## \file install-op-parental-control2.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=$idir/install-op-/install-op-parental-control2

file=$bdir/ctpar/log.php
if notFile $file; then
    cp $dir/log.php $file
fi

file=$bdir/ctpar/users.php
if notFile $file; then
    if [ -f $dir/users-pr-.php ]; then
        cp $dir/users-pr-.php $file
    fi
fi

file=/etc/apache2/sites-enabled/ctpar.conf
if notFile $file; then
    sudoRoot cp $idir/install-op-/install-op-parental-control2/ctpar.conf $file
    sudoRoot systemctl restart apache2
fi

cat <<EOF

Todo :
adb install Kiwi\ Browser\ -\ Fast\ \&\ Quiet_120.0.6099.116_Apkpure.apk
adb shell "cd /storage/self/primary/Android/data && mkdir com.github.kiwibrowser"
adb push kiwictp.user.js manifest.json /storage/self/primary/Android/data/com.github.kiwibrowser/
adb shell pm list packages | sort
adb shell pm uninstall --user 0 com.android.chrome
adb shell pm uninstall --user 0 com.sec.android.app.sbrowser
adb shell pm uninstall --user 0 com.google.android.googlequicksearchbox

adb shell pm uninstall --user 0 com.samsung.android.beaconmanager  # smartthings
adb shell pm uninstall --user 0 com.samsung.android.email.provider
adb shell pm uninstall --user 0 com.samsung.android.fmm  # find my mobile
adb shell pm uninstall --user 0 com.samsung.android.game.gamehome  # game launcher
adb shell pm uninstall --user 0 com.samsung.android.game.gametools
adb shell pm uninstall --user 0 com.samsung.android.scloud
adb shell pm uninstall --user 0 com.samsung.android.spay
adb shell pm uninstall --user 0 com.samsung.android.spayfw
adb shell pm uninstall --user 0 com.samsung.android.voc  # samsung members
adb shell pm uninstall --user 0 com.samsung.android.app.mirrorlink  # car link
adb shell pm uninstall --user 0 com.sec.android.app.shealth
adb shell pm uninstall --user 0 com.sec.spp.push

adb shell pm uninstall --user 0 com.google.android.gms  # google mobile services
adb shell pm uninstall --user 0 com.google.android.gm  # gmail
adb shell pm uninstall --user 0 com.google.android.music
adb shell pm uninstall --user 0 com.google.android.talk
adb shell pm uninstall --user 0 com.google.android.videos
adb shell pm uninstall --user 0 com.google.android.youtube
adb shell pm uninstall --user 0 com.google.android.apps.docs  # drive
adb shell pm uninstall --user 0 com.google.android.apps.maps
adb shell pm uninstall --user 0 com.google.android.apps.photos
adb shell pm uninstall --user 0 com.google.android.gsf  # play store
adb shell pm uninstall --user 0 com.android.vending  # play store

adb shell pm uninstall --user 0 com.facebook.appmanager
adb shell pm uninstall --user 0 com.facebook.katana
adb shell pm uninstall --user 0 com.facebook.services
adb shell pm uninstall --user 0 com.facebook.system
adb shell pm uninstall --user 0 com.linkedin.android
adb shell pm uninstall --user 0 com.microsoft.skydrive  # onedrive
adb shell pm uninstall --user 0 de.axelspringer.yana.zeropage  # upday
adb shell pm uninstall --user 0 com.android.nfc
adb shell pm uninstall --user 0 com.android.printspooler

adb install 'Tuner & Metronome_7.16_Apkpure.apk'
adb install calendar-fdroid-release.apk
adb install music-player-fdroid-release.apk
adb install io.timelimit.android.open_216.apk

Timelimit Alowed Apps :
 Always On Display
 Appareil photo
 Application MTP
 Calculatrice
 Calendrier
 Call+
 CaptivePortalLogin
 Capture Samsung
 Clavier Samsung
 Contacts
 Duolingo
 Decoupage de videos
 Editeur de photos
 Fonds d'ecran
 Galerie
 Harmony Music
 Horloge
 Lecteur de musique
 Lecteur video
 Loupe
 Mes fichiers
 Messages
 Samsung Notes
 Soundcorset accordeur et metronome
 Stockage de medias
 Selection de sons
 Telephone incallui
 WhatsApp
 Ecran d'accueil de Samsung Experience

EOF
