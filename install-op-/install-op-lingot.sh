# ---------------------------------------------------------------------------- #
## \file install-op-lingot.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$home/.config/lingot/lingot.conf
if notFile $file; then
    lingot >>$log 2>&1 &
    sleep 2
    pkill -15 lingot
fi

configure()
{
    if notGrep "\"$1\":$2" $file; then
        sed -i "s/$1\":.*,/$1\":$2,/" $file
    fi
}

configure ROOT_FREQUENCY_ERROR 8.000
configure MINIMUM_FREQUENCY 82.410
configure MAXIMUM_FREQUENCY 1318.510
