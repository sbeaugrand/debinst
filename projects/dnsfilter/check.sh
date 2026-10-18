#/bin/bash
# ---------------------------------------------------------------------------- #
## \file check.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
since=${1:-1w}

sudo journalctl -u tcpdump-dns -S -$since |\
 grep -v -f allow |\
 grep -v -f deny |\
 grep 'tcpdump-dns.sh' |\
 grep '\.$' |\
 awk '{ print $NF }' |\
 sed 's/\.$//' |\
 sort |\
 uniq -c |\
 sort -n
