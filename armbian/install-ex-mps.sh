# ---------------------------------------------------------------------------- #
## \file install-ex-mps.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if ! isDir /mnt/mp3/mp3; then
    cat <<EOF

Todo :
sudo mount /dev/sda1 /mnt/mp3
../0install.sh install-op-mpd.sh
sudo umount /mnt/mp3

EOF
fi
