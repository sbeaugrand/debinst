# ---------------------------------------------------------------------------- #
## \file install-00-pkg.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if ((`cat /proc/net/arp | wc -l` > 1)); then
    export DEBIAN_FRONTEND=noninteractive

    apt-get -q -y update >>$log
    apt-get -q -y dist-upgrade >>$log

    list=`cat install-00-pkg.txt | sed 's/ *#.*//' | tr '\n' ' '`
    apt-get -q -y install --no-install-recommends $list >>$log
fi
