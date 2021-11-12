# ---------------------------------------------------------------------------- #
## \file install-00-pkg.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if ((`cat /proc/net/arp | wc -l` > 1)); then
    export DEBIAN_FRONTEND=noninteractive

    echo " info: apt-get update ..."
    apt-get -q -y update >>$log 2>&1
    echo " info: apt-get dist-update ..."
    apt-get -q -y dist-upgrade >>$log 2>&1

    list=`cat install-00-pkg.txt | sed 's/ *#.*//' | tr '\n' ' '`
    echo " info: apt-get install $list"
    apt-get -q -y install --no-install-recommends $list >>$log 2>&1
fi
