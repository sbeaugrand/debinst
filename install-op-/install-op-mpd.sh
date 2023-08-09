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
    sudoRoot sed -i.bak "'s#/var/lib/mpd/music#$MP3DIR/mp3#'" $file
    sudoRoot sed -i.bak "'s#/var/lib/mpd/playlists#$MP3DIR/mp3#'" $file
fi

if notGrep '^audio_output' $file; then
    cp $file $tmpf
    cat >>$tmpf <<EOF

audio_output {
    type        "alsa"
    name        "My ALSA Device"
}
EOF
    sudoRoot cp $tmpf $file
    rm $tmpf
fi

if ! systemctl -q is-enabled mpd; then
    sudoRoot systemctl enable mpd
fi
sudoRoot systemctl restart mpd
mpc update
