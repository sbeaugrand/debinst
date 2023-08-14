# ---------------------------------------------------------------------------- #
## \file install-op-mpd.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$MP3DIR" ]; then
    echo " error: MP3DIR is not set"
    return 1
fi

file=/etc/mpd.conf
if notGrep "$MP3DIR" $file; then
    sudoRoot sed -i "'s#/var/lib/mpd/music#$MP3DIR/mp3#'" $file
    sudoRoot sed -i "'s#/var/lib/mpd/playlists#$MP3DIR/mp3#'" $file
    sudoRoot sed -i "'s#/var/lib/mpd/tag_cache#$MP3DIR/tag_cache#'" $file
    sudoRoot sed -i "'s#/var/lib/mpd/state#$MP3DIR/state#'" $file
    sudoRoot sed -i "'s#/var/lib/mpd/sticker.sql#$MP3DIR/sticker.sql#'" $file
fi

if notGrep '^audio_output' $file; then
    cp $file $tmpf
    cat >>$tmpf <<EOF

audio_output {
    type       "alsa"
    name       "ALSA Device"
    mixer_type "none"
}

max_playlist_length "65536"
EOF
    sudoRoot cp $tmpf $file
    rm $tmpf
fi

if systemctl -q is-enabled mpd; then
    sudoRoot systemctl disable mpd
fi
sudoRoot systemctl restart mpd
#mpc -w update
#sudoRoot systemctl stop mpd
mpc update
logToto "see update progress with : mpc listall | wc -l"
logToto "sudo systemctl stop mpd"
