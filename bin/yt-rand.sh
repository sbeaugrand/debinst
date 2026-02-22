#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file yt-rand.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
dir=~/.local/share/yt-rand
file=$dir/list

if [ "$1" = "-h" ] || [ ! -f $file ]; then
    mkdir -p $dir
    cat <<EOF

# Playlists

cd /tmp && rm -f UC*
yt-dlp -s --write-pages https://www.youtube.com/@Svenir/playlists  # ctrl-c
cat UC* | sed 's@/playlist?list=@\nhttps://www.youtube.com/playlist?list=@g' | grep '^https:' | cut -d'"' -f1 | tee $dir/svenir.list
cp $dir/svenir.list $dir/list

# Videos

cd /tmp && rm -f UC*
yt-dlp -s --write-pages https://www.youtube.com/@metallumuniversum8925/videos  # ctrl-c
cat UC* | sed 's@/watch?v=@\nhttps://www.youtube.com/watch?v=@g' | grep '^https:' | cut -d'"' -f1 | cut -d'&' -f1 | uniq | tee $dir/metallum.list
cp $dir/metallum.list $dir/list

EOF
    exit 0
fi

max=`cat $file | wc -l`
((rand = RANDOM * max / 32768 + 1))
line=`head -n $rand $file | tail -n 1`
if [ -z "$line" ]; then
    echo "error: $file +$rand"
    exit 2
fi
echo $line
chromium $line
echo -n "retirer de la liste ? [o/N] "
read ret
if [ "$ret" = o ]; then
    sed -i ${rand}d $file
fi
echo "`cat $file | wc -l` lignes"
