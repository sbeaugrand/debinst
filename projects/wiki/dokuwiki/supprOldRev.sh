#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file supprOldRev.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=/usr/share/dokuwiki/data
list=`ls $dir/pages | sed 's/\.txt//g'`
for f in $list; do
    file=$dir/meta/$f.changes
    if [ -f $file ]; then
        n=`cat $file | wc -l`
        if ((n < 2)); then
            continue
        fi
        for ((i = 1; i < n; ++i)); do
            k=`cat $file | head -n $i | tail -n 1 | awk '{ print $1 }'`
            rm $dir/attic/dokuwiki.$k.txt.gz
        done
        tail -n 1 $file >$file.tmp
        mv $file.tmp $file
    fi
done
