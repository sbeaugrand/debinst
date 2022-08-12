#!/bin/bash

prepare()
{
    if file $1 | grep ISO-8859 >/dev/null 2>&1; then
        iconv -f ISO-8859-1 -t UTF-8 $1 >$1.tmp
        mv $1.tmp $1
    fi
    cat $1 |\
    tr -d '\r' |\
    sed 's/^ *//' |\
    sed 's/ *$//' |\
    cat >$1.tmp
    if ! diff $1 $1.tmp; then
        mv $1.tmp $1
    else
        rm $1.tmp
    fi
}

prepare recettes.txt

cat recettes.txt | cut -c10- | sed "s/'/ /g" >recettes.tmp

php sort.php >termes.tmp

if ! diff termes.php termes.tmp; then
    mv termes.tmp termes.php
else
    rm termes.tmp
fi
rm recettes.tmp

prepare ingredients.txt

# unicité
cat recettes.txt | cut -c10- >recettes.tmp
n=`cat recettes.tmp | wc -l`
for ((i = 1; i <= n; ++i)); do
    f=`head -n $i recettes.tmp | tail -n 1`
    c=`grep -c "^$f\$" ingredients.txt`
    if (($c != 1)); then
        echo "$c $f"
    fi
done
rm recettes.tmp
