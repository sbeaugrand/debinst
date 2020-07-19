# ---------------------------------------------------------------------------- #
## \file res.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
output=${OUTPUT:-`xrandr | grep -m 1 connected | cut -d ' ' -f 1`}

if [ -z "$2" ]; then
    echo "Usage: `basename $0` <h-resolution> <v-resolution> [refresh]"
    exit 1
fi
h=$1
v=$2
r=${3:-60}
m=${h}x${v}_$r.00

echo xrandr --newmode `gtf $h $v $r | grep Modeline | sed 's/  Modeline //'`
eval xrandr --newmode `gtf $h $v $r | grep Modeline | sed 's/  Modeline //'`
echo xrandr --addmode $output $m
eval xrandr --addmode $output $m
echo xrandr --output $output --mode $m
eval xrandr --output $output --mode $m
