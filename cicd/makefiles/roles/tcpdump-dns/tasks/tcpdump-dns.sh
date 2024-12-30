#!/bin/bash
# ---------------------------------------------------------------------------- #
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note /sbin/tcpdump-pr-dns.sh example :
##       #!/bin/bash
##       translate()
##       {
##           awk '{
##               switch (substr($3, 0, 11)) {
##               case "10.66.0.123" : printf "Papa   %s\n",$8; break;
##               case "10.66.0.11." : printf "Papi   %s\n",$8; break;
##               case "10.66.0.111" : printf "Papo   %s\n",$8; break;
##               default : printf "$3 $8"; break;
##           }'
##       }
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

tcpdump -i $iface -l "dst $ipdns and port 53" | sed 's/] /]/' | translate
