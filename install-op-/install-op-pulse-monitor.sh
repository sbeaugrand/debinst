# ---------------------------------------------------------------------------- #
## \file install-op-pulse-monitor.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note arecord -f cd -t wav -D pulse_monitor output.raw
##       ffmpeg -f alsa -i pulse_monitor output.wav
# ---------------------------------------------------------------------------- #
file=$home/.asoundrc
if notFile $file; then
    touch $file
fi

if notGrep "pcm.pulse_monitor" $file; then
    device=`pactl list | grep "\.monitor" |\
 awk -F ": " '{ print $2 }' | sort -u | head -n 1`
    cat >>$file <<EOF
pcm.pulse_monitor {
    type pulse
    device $device
}

ctl.pulse_monitor {
    type pulse
    device $device
}
EOF
fi
