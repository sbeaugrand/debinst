#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file raw2mp3.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# ffmpeg -i .mp4 -vcodec null -acodec pcm_s16le output.wav
# mv output.wav output.raw
# ---------------------------------------------------------------------------- #
silence_duration=0.01
if [ -n "$1" ]; then
    silence_duration=$1
fi

nbraw=`ls *.raw | wc -l`
for ((i = 1; i <= nbraw; i++)); do
    if [ ! -f t.txt ]; then
        echo "warning: t.txt not found"
    elif grep SNG_TITLE t.txt >/dev/null; then
        cp t.txt t.bak
        sed 's/","/\n/g' t.bak | grep SNG_TITLE | cut -d '"' -f 3 >t.txt
        cat t.txt
        cat t.txt | wc -l
    fi
    raw=`ls *.raw | head -n $i | tail -1`
    rate=`ffprobe -show_streams $raw 2>/dev/null | grep sample_rate | cut -d '=' -f 2`
    echo -n "split $raw at $rate Hz ? (o/N) "
    read ret
    if [ "$ret" = o ]; then
        sox -t s16 -c 2 -r $rate $raw 0.wav silence \
            1 $silence_duration 0% 1 $silence_duration 0% : newfile : restart
        tmp=/tmp/wav2mp3.tmp
        ls 0???.wav >$tmp
        nbwav=`ls 0???.wav | wc -l`
        for ((j = 1; j <= nbwav; j++)); do
            src=`head -n $j $tmp | tail -n 1`
            size=`stat -c "%s" $src`
            size=`printf "%10d" $size`
            echo `soxi -d $src`" $size $src"
        done
        for ((j = 1; j <= nbwav; j++)); do
            src=`head -n $j $tmp | tail -n 1`
            for ((k = 1;; k++)); do
                dst=`printf "%02d" $k`.wav
                if [ -f $dst ]; then
                    continue;
                fi
                if [ ! -f t.txt ] ||
                    [ -n "`head -n $k t.txt | tail -1`" ]; then
                    break;
                fi
            done
            echo -n "$src ==> $dst ? (O/n/d) "
            read ret
            if [ "$ret" = d ]; then
                rm $src
            elif [ "$ret" != n ]; then
                mv $src $dst
            fi
        done
        rm $tmp
    fi
done
ls -l

bitrate=192
echo -n "bitrate ? [$bitrate] "
read ret
if [ -n "$ret" ]; then
    bitrate=$ret
fi

nbwav=`ls *.wav | wc -l`
for ((i = 1; i <= nbwav; i++)); do
    wav=`ls *.wav | head -n $i | tail -1`
    if [ -f t.txt ]; then
        j=${wav:0:2}
        k=`echo $j | awk '{ print $0+0 }'`
        mp3="$j - `head -n $k t.txt | tail -1`.mp3"
    else
        mp3=${wav/%.wav/.mp3}
    fi
    if [ -f "$mp3" ]; then
        echo -n "$mp3 existe, ecraser ? (o/N) "
        read ret
        if [ "$ret" != o ]; then
            continue
        fi
    fi
    echo "$wav ==> $mp3"
    lame -q 0 -b $bitrate --cbr -S "$wav" "$mp3"
done
