#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file csvtranspose.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$2" ]; then
    echo "Usage: `basename $0` <src> <dst>"
    exit 1
fi
src=$1
dst=$2
cat /dev/null >$dst

n=`cat $src | wc -l`
for((i = 1; i <= n; i++)); do
    v=`printf "\10$i"`
    eval $v=\(`cat $src | head -n $i | tail -n 1 |\
      tr -d ' ' | tr ';' ' ' | tr ',' '.' | tr -d '()'`\)
done
m=${#A[*]}
m=$((m-1))
for((j = 0; j < m; j++)); do
    for((i = 1; i <= n; i++)); do
        v=`printf "\10$i"`
        eval echo -n "\${$v[$j]}\ " >>$dst
    done
    echo >>$dst
done
