#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file tcpdump-dns.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
iface=$1
ipdns=$2
tcpdump="tcpdump -i $iface -l --immediate-mode"

file=/sbin/tcpdump-pr-dns.py
if [ -f $file ]; then
    $tcpdump "dst $ipdns and port 53" | python3 -u $file
else
    $tcpdump "dst $ipdns and port 53"
fi
