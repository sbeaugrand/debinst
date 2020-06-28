# ---------------------------------------------------------------------------- #
## \file install-05-asoundrc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/etc/asound.conf
if notFile $file; then
    cat >$file <<EOF
pcm.!default {
        type hw
        card 1
}

ctl.!default {
        type hw
        card 1
}
EOF
fi

amixer -q set 'DAC LINEOUT Right' 100% unmute
amixer -q set 'DAC LINEOUT Left' 100% unmute
