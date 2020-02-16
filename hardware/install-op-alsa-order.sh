# ---------------------------------------------------------------------------- #
## \file install-op-alsa-order.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=/etc/modprobe.d/50-alsa.conf
if notFile $file || notGrep "options snd_hda_intel index" $file; then
    echo "options snd_hda_intel index=1,0" >>$file
    /sbin/modprobe -r snd_hda_intel
    /sbin/modprobe snd_hda_intel
fi
