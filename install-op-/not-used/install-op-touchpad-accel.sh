# ---------------------------------------------------------------------------- #
## \file install-op-touchpad-accel.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$home/.bashrc

if notGrep Accel $file; then
    cat >>$file <<EOF
xinput list-props 'ImPS/2 Generic Wheel Mouse' |\
 grep 'Device Accel Constant Deceleration' |\
 awk '{ exit(\$NF == 0.5) }' && xinput set-float-prop\
 'ImPS/2 Generic Wheel Mouse' 'Device Accel Constant Deceleration' 0.5
EOF
fi
