# ---------------------------------------------------------------------------- #
## \file install-op-mpd.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$MP3DIR" ]; then
    MP3DIR=/mnt/mp3
    echo " warn: MP3DIR=$MP3DIR"
fi

file=/etc/mpd.conf
if notGrep "$MP3DIR" $file; then
    sudoRoot sed -i "'s/^db_file/#db_file/'" $file
    cp $file $tmpf
    cat >>$tmpf <<EOF

music_directory    "$MP3DIR/mp3"
playlist_directory "$MP3DIR/mp3"
db_file            "$MP3DIR/db"
state_file         "$MP3DIR/state"
sticker_file       "$MP3DIR/sticker.sql"

user "$user"

bind_to_address "/run/mpd.sock"

audio_output {
    type       "alsa"
    name       "ALSA Device"
    mixer_type "none"
}

EOF
    sudoRoot cp $tmpf $file
    rm $tmpf
fi

if systemctl -q is-enabled mpd; then
    sudoRoot systemctl disable mpd
fi
if systemctl -q is-enabled mpd.socket; then
    sudoRoot systemctl disable mpd.socket
fi
