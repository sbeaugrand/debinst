# ---------------------------------------------------------------------------- #
## \file install-op-lingot.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
file=$home/.lingot/lingot.conf
if notFile $file; then
    sudo -u $user lingot >>$log 2>&1 &
    sleep 2
    pkill -15 lingot
fi

configure()
{
    if notGrep "$1 = $2" $file; then
        sed -i "s/$1 = .*/$1 = $2/" $file
    fi
}

configure "ROOT_FREQUENCY_ERROR" "8.000 # cents"
configure "MINIMUM_FREQUENCY" "82.410 # Hz"
configure "MAXIMUM_FREQUENCY" "1318.510 # Hz"

