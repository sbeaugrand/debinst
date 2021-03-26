# ---------------------------------------------------------------------------- #
## \file install-op-sounds.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$home/.local/share/sounds/__custom/message-new-instant.oga
if notFile $file; then
    cp $bdir/start_race.ogg $file
fi

file=$home/.local/share/sounds/__custom/alarm-clock-elapsed.oga
if notFile $file; then
    cp $bdir/NBK-Sonnerie01-casonne.mp3.oga $file
fi

rm $home/.cache/event-sound-cache.tdb.*
