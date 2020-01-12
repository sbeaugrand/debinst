# ---------------------------------------------------------------------------- #
## \file install-op-ipod.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #

cat <<EOF

sudo apt install gtkpod
/dev/sdc2 /media/$user/ipod auto users,noauto 0 0
mount /media/$user/ipod

EOF
