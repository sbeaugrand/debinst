# ---------------------------------------------------------------------------- #
## \file install-op-audio.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
modprobe snd_bcm2835
amixer cset numid=3 1 >>$log
sudo -u pi alsamixer
alsactl store
