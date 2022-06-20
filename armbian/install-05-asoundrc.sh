# ---------------------------------------------------------------------------- #
## \file install-05-asoundrc.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ `uname -n` = "rockpi-s" ]; then
    file=/etc/asound.conf
    if notFile $file; then
        cat >$file <<EOF
pcm.!default {
        type hw
        card rockchiprk3308a
}

ctl.!default {
        type hw
        card rockchiprk3308a
}
EOF
    fi

    return 0
fi

file=/boot/armbianEnv.txt
if isFile $file; then
    if notGrep "analog-codec" $file; then
        if grep -q "^overlays" $file; then
            sed -i 's/\(^overlays=.*\)/\1 analog-codec/' $file || return 1
        else
            echo "overlays=analog-codec" >>$file
        fi
    fi
fi
