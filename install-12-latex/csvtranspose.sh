#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: `basename $0` <src> <dst>"
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
