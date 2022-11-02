#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file find-ip.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
netId=192.168.0
i=${1:-11}
color="\033[33;1m"
reset="\033[0m"

trap "echo; exit" SIGINT

while ! nc -zvn $netId.$i 22; do
    ((i++))
done
ip=$netId.$i

if ssh-keygen -F pi >/dev/null; then
    echo -ne "$color"
    echo " todo: ssh-keygen -R pi"
    echo -ne "$reset"
fi
if ssh-keygen -F $ip >/dev/null; then
    echo -ne "$color"
    echo " todo: ssh-keygen -R $ip"
    echo -ne "$reset"
fi
if ! grep -q "^$ip pi" /etc/hosts; then
    echo -ne "$color"
    echo " todo: sudo vi /etc/hosts  # $ip pi"
    echo -ne "$reset"
fi
