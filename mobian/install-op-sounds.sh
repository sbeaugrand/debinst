# ---------------------------------------------------------------------------- #
## \file install-op-sounds.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note test with "fbcli -E alarm-clock-elapsed"
# ---------------------------------------------------------------------------- #
dir=/usr/local/share/sounds/freedesktop/stereo
if notDir $dir; then
    mkdir -p $dir
fi

file=/usr/local/share/sounds/freedesktop/index.theme
if notFile $file; then
    cp /usr/share/sounds/freedesktop/index.theme $file
fi

file=$dir/message-new-instant.oga
if notFile $file; then
    cp $bdir/start_race.ogg $file
fi

file=$dir/alarm-clock-elapsed.oga
if notFile $file; then
    cp $bdir/NBK-Sonnerie01-casonne.mp3.oga $file
fi

rm -f $home/.cache/event-sound-cache.tdb.*
