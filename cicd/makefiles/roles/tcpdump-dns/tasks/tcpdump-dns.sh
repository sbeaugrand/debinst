#!/bin/bash
# ---------------------------------------------------------------------------- #
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
##
## \note /sbin/tcpdump-pr-dns.sh example :
##       #!/bin/bash
##       translate()
##       {
##           awk '{
##               switch (substr($3, 0, 11)) {
##               case "10.66.0.123" : printf "Papa   %s\n",$8; break;
##               case "10.66.0.11." : printf "Papi   %s\n",$8; break;
##               case "10.66.0.111" : printf "Papo   %s\n",$8; break;
##               default : printf "%s %s\n",$3,$8; break;
##           }'
##       }
##
## \note /sbin/tcpdump-pr-dns.py example :
##       #!/usr/bin/env python3
##       import sys
##       for line in sys.stdin:
##           line = line.strip()
##           fields = line.split()
##           if len(fields) < 7 or fields[0][0] not in '012':
##               if len(line) > 0:
##                   print(line)
##               continue
##           url = fields[7]
##           ip = fields[2]
##           match ip[0:11]:
##               case "10.66.0.123": ip = 'Papa  '
##               case "10.66.0.11.": ip = 'Papi  '
##               case "10.66.0.111": ip = 'Papo  '
##           print(f'{fields[0]} {ip} {url}')
# ---------------------------------------------------------------------------- #
iface=$1
ipdns=$2

file=/sbin/tcpdump-pr-dns.sh
if [ -f $file ]; then
    source $file
else
    translate()
    {
        cat
    }
fi

#tcpdump -i $iface -l "dst $ipdns and port 53" | sed 's/] /]/' | translate
#tcpdump -i $iface -l "dst $ipdns and port 53" | python3 -u /sbin/translate.py
tcpdump -i $iface -l "dst $ipdns and port 53"
