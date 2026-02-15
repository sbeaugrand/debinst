#!/bin/bash
# leet.sh -rs 8
#
# ABCDEFGHIJKLMNOPQRSTUVWXYZ
# abcdef6 1  1  0  257    7
#                9       8 2
#
if [ "${1:0:1}" = "-" ]; then
    n=`echo -n $1 | wc -c`
    for ((i = 1; i < n; ++i)); do
        x="$x\|${1:$i:1}"
    done
    shift
fi
n=${1:-8}
sed 's@/.*@@' /usr/share/hunspell/fr.dic |\
    sed -n "/^.\{$n\}$/p" |\
    grep -v "\(h\|j\|k\|m\|n\|p\|q\|u\|v\|w\|x\|z\|'\|-$x\)" |\
    more
