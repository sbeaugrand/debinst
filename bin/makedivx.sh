#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file makedivx.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# This is an interactive shell script to rip DVD and encode DIVX.
# It can :
# - rip, encode audio, encode video, separately into different sessions
# - crop the black bars with autodetection
# - choose the best resolution for the 16:9 or 4:3 format
# - maximize volume (with a mencoder patch)
# - extract subtitle into a separated text file (with transcode tools)
# - split the AVI
# The video bitrate is a bit different from the mencoder recommendation, it's
# for a maximum filling for one CD, or to leave a margin to split the AVI.
# Type makedivx.sh --help for options.
# ---------------------------------------------------------------------------- #
# Date        Author               Comments
# ---------------------------------------------------------------------------- #
# 25/02/2003  Sebastien Beaugrand  Creation
# 20/04/2004  Sebastien Beaugrand  Add crop autodetection process
# 30/07/2004  Sebastien Beaugrand  Add volume maximization and AVI spliting
# 17/08/2004  Sebastien Beaugrand  Add volume maximization with normalize
# 21/09/2004  Sebastien Beaugrand  Add automatic title with lsdvd
# 24/09/2006  Sebastien Beaugrand  Encode audio and video at the same time to
#                                    avoid desynchronization
# ---------------------------------------------------------------------------- #
# Gray format : ffmpeg -i 01.avi -vf format=gray -pix_fmt yuv420p 01.mp4
# Limits the CPU usage : cpulimit -e mencoder -l 50
# ---------------------------------------------------------------------------- #
gnu=true
lang=fr
ratemin=800
marginbr=6
splitmarginsize=30
tcpath=~/tmp/transcode
#mpeg4opt=vhq:v4mv:trell:vqmin=2:vlelim=-4:vcelim=9:lumi_mask=0.05:dark_mask=0.01
mpeg4opt=vhq:v4mv:trell:vqmin=2:o=luma_elim_threshold=-4
mpeg4opt=$mpeg4opt:o=chroma_elim_threshold=9:lumi_mask=0.05:dark_mask=0.01
red="\033[31;1m"
green="\033[32;1m"
blue="\033[34;1m"
reset="\033[0m"

# ---------------------------------------------------------------------------- #
# Print a fatal error
# ---------------------------------------------------------------------------- #
fatal()
{
    echo -e "$blue$1\npress enter to quit$reset"
    read
    exit -1
}

# ---------------------------------------------------------------------------- #
# Read from standard input
# ---------------------------------------------------------------------------- #
myRead()
{
    echo -ne "$green$1 [$2] $reset"
    if [ $auto = no ]; then
        read ret
        if [ -z "$ret" ]; then
            ret=$2
        fi
    else
        echo
        ret=$2
    fi
}

# ---------------------------------------------------------------------------- #
# Read lsdvd
# ---------------------------------------------------------------------------- #
readLsdvd()
{
    if [ ! -r lsdvd.txt ]; then
        if type lsdvd &>/dev/null ; then
            lsdvd -q $dev | grep a >lsdvd.txt
        else
            echo -e "$blue"
            echo "for automatic value of the title install lsdvd"
            echo -e "$reset"
        fi
    fi
}

# ---------------------------------------------------------------------------- #
# Select title
# ---------------------------------------------------------------------------- #
selectTitle()
{
    if [ -z "$title" ]; then
        title=1
        readLsdvd
        if [ -r lsdvd.txt ]; then
            cat lsdvd.txt
            title=`tail -n 1 lsdvd.txt`
            title=`echo ${title:0-2:2} | awk '{ print $0+0 }'`
        fi
        if [ $title = 0 ]; then
            echo -e "${blue}lsdvd error$reset"
            title=1
        fi
        myRead "title ?" $title
        checkNumericValue $ret "title" 1
        title=dvd://$ret
        if [ -n "$dev" ]; then
            title="-dvd-device $dev $title"
        fi
    fi
}

# ---------------------------------------------------------------------------- #
# Read the DVD structure
# ---------------------------------------------------------------------------- #
readStructure()
{
    if [ ! -r structure.txt ]; then
        selectTitle
        mplayer $title -v -nosound -novideo >structure.txt 2>/dev/null
    fi
}

# ---------------------------------------------------------------------------- #
# Select title and angle
# ---------------------------------------------------------------------------- #
selectTitleAndAngle()
{
    selectTitle
    readStructure
    if [ -z "$angle" ]; then
        n=`grep "angles" structure.txt`
        n=${n:10:1}
        if ((n > 1)); then
            myRead "angle ?" 1
            checkNumericValue $ret "angle" 1
            angle="-dvdangle $ret"
        fi
    fi
}

# ---------------------------------------------------------------------------- #
# Select chapters
# ---------------------------------------------------------------------------- #
selectChapters()
{
    if [ -z "$first" ] || [ -z "$last" ]; then
        selectTitle
        readLsdvd
        myRead "first chapter ?" 1
        first=$ret
        last=`echo $title | awk 'BEGIN { FS="//" } { print $2 }'`
        last=`head -n $last lsdvd.txt | tail -n 1 | cut -d ' ' -f 6 |\
          tr -d ',\n' | awk '{ print $0+0 }'`
        myRead "last chapter ?" $last
        last=$ret
    fi
}

# ---------------------------------------------------------------------------- #
# Rip the DVD
# ---------------------------------------------------------------------------- #
makeDump()
{
    list=
    if [ -f dump.01 ]; then
        myRead "do you want to delete dump files ? (y/n)" "n"
        if [ $ret = y ]; then
            rm -f dump.*
        fi
    fi
    selectTitleAndAngle
    selectChapters
    for ((i = first; i <= last; ++i)); do
        file=dump.`printf %02d $i`
        list="$list $file"
        if [ -f $file ]; then
            myRead "do you want to overwrite $file ? (y/n)" "n"
            if [ $ret = n ]; then
                continue
            fi
        fi
        echo -e "${blue}writing $file$reset"
        # With mencoder it doesn't work well, then we use mplayer to dump.
        # On some DVD the volume can be different when we select a chapter,
        # in this case it's better to encode directly from the DVD (this
        # problem was encountered only once on "Rammstein Live Aus Berlin").
        mplayer $title $angle -chapter $i-$i -dumpstream -dumpfile $file
    done
}

# ---------------------------------------------------------------------------- #
# Select input
# ---------------------------------------------------------------------------- #
selectInput()
{
    if [ $direct = y ]; then
        selectTitleAndAngle
    elif [ -z "$list" ]; then
        list=
        if [ -z "$first" ] || [ -z "$last" ]; then
            myRead "first chapter ?" 1
            first=$ret
            last=`ls -1 --indicator-style=none dump.* 2>/dev/null | tail -n 1`
            if [ -n "$last" ]; then
                last=`echo ${last:0-2:2} | awk '{ print $0+0 }'`
            else
                fatal "cannot access to any dump file"
            fi
            myRead "last chapter ?" $last
            last=$ret
        fi
        for ((i = first; i <= last; ++i)); do
            file=dump.`printf %02d $i`
            if [ ! -r $file ]; then
                fatal "cannot access to $file"
            fi
            list="$list $file"
        done
        echo -e "${blue}using the files : $reset"
        echo -e $list
    fi
}

# ---------------------------------------------------------------------------- #
# Maximize volume
# ---------------------------------------------------------------------------- #
maximizeVolume()
{
    if [ $volume != 1 ]; then
        return
    fi

    myRead "maximize volume ? (y/n)" y
    if [ $ret = y ]; then
        if [ $normalize = "true" ]; then
            if [ $direct = y ]; then
                mplayer $title $angle -vo null\
                  -ao pcm:file=sound.wav -alang $lang
                volume=`normalize -n -a 1 --fractions sound.wav`
                echo $volume
                volume=`echo $volume | awk 'BEGIN { FS = " " } { print 1/$2 }'`
            else
                myRead "only one temporary sound file ? (y/n)" y
                if [ $ret = y ]; then
                    if [ -f sound.wav ]; then
                        myRead "do you want to overwrite sound.wav ? (y/n)" "n"
                        if [ $ret = y ]; then
                            cat $list |\
                             mplayer -vo null -ao pcm:file=sound.wav -aid $aid -
                        fi
                    else
                        cat $list |\
                          mplayer -vo null -ao pcm:file=sound.wav -aid $aid -
                    fi
                    volume=`normalize -n -a 1 --fractions sound.wav`
                    echo $volume
                    volume=\
                      `echo $volume | awk 'BEGIN { FS = " " } { print 1/$2 }'`
                else
                    list2=
                    for ((i = first; i <= last; ++i)); do
                        file1=dump.`printf %02d $i`
                        file2=sound`printf %02d $i`.wav
                        list2="$list2 $file2"
                        if [ -f $file2 ]; then
                            myRead "do you want to overwrite $file2 ? (y/n)" "n"
                            if [ $ret = n ]; then
                                continue
                            fi
                        fi
                        echo -e "${blue}writing $file2$reset"
                        mplayer $file1 -vo null -ao pcm:file=$file2 -aid $aid
                    done
                    normalize -n -a 1 --fractions -- $list2 |\
                      grep "sound" >normalize.txt
                    cat normalize.txt
                    volume=`awk '\
                      BEGIN { FS = " "; m = 0 }\
                      { v = strtonum($2); if (v > m) m = v }\
                      END { if (m > 0) print 1/m; else print 1 }' normalize.txt`
                fi
            fi
        else
            if [ ! -r volume.txt ]; then
                echo -e "${blue}warning: mencoder must be patched for this"
                echo -e "see http://beaugrand.chez.com/"
                echo -e "or use normalize with -n option"
                echo -e "please wait, it takes a few minutes...$reset"
                if [ $direct = y ]; then
                    mencoder $title $angle -ovc frameno -o /dev/null -oac pcm\
                      -alang $lang -quiet $mencOpt 2>/dev/null |\
                      grep "gain=" >volume.txt
                else
                    echo\
                    mencoder -ovc frameno -o /dev/null -oac pcm\
                      -aid $aid -quiet $mencOpt $list
                    mencoder -ovc frameno -o /dev/null -oac pcm\
                      -aid $aid -quiet $mencOpt $list 2>/dev/null |\
                      grep "gain=" >volume.txt
                fi
            fi
            tail -n 1 volume.txt
            volume=`tail -n 1 volume.txt | cut -d "=" -f 3`
            if [ -z "$volume" ]; then
                echo -e "${blue}it seems mencoder is not patched for this"
                echo -e "please see http://beaugrand.chez.com/"
                echo -e "or use normalize with -n option$reset"
                volume=1
            fi
        fi
        echo -ne $bel
        myRead "volume ?" $volume
        volume=$ret
    fi
}

# ---------------------------------------------------------------------------- #
# Select the subtitle
# ---------------------------------------------------------------------------- #
selectSubtitleId()
{
    readStructure
    sid=`grep "sid" structure.txt | grep $lang | tail -n 1`
    sid=${sid:18:2}
    if [ -z "$sid" ]; then
        sid=`grep -m 1 "sid" structure.txt`
        sid=${sid:18:2}
        if [ -z "$sid" ]; then
            echo -e "${blue}no subtitle found$reset"
            return
        fi
    fi
    myRead "sid ?" $sid
    sid="-sid $ret"
}

# ---------------------------------------------------------------------------- #
# Select scale
# ---------------------------------------------------------------------------- #
selectScale()
{
    if [ -z "$res" ]; then
        # Dimensions are adapted to the majority of the resolutions used
        if [ $aspect = '1' ]; then
            myRead "resolution :\
              \n (1) 720:400\n (2) 640:352\n (3) 576:320\n (4) 512:288\n" "1"
            case $ret in
                1) res=720:400 ;;  # 720x405
                2) res=640:352 ;;  # 640x360
                3) res=576:320 ;;  # 576x324
                4) res=512:288 ;;
            esac
        elif [ $aspect = '2' ]; then
            myRead "resolution :\
              \n (1) 720:528\n (2) 640:480\n (3) 576:432\n (4) 512:384\n" "2"
            case $ret in
                1) res=720:528 ;;  # 720x540
                2) res=640:480 ;;
                3) res=576:432 ;;
                4) res=512:384 ;;
            esac
        fi
    fi
    # The 4:3 videos are often interlaced
    if [ $aspect != '1' ] && [ -z "$deinterlace" ]; then
        myRead "deinterlace ? (y/n)" "n"
        if [ $ret = y ]; then
            deinterlace="pp=fd,"
        fi
    fi
    if [ -n "$res" ]; then
        if [ -n "$crop" ]; then
            resx=`echo $res  | cut -d ':' -f 1`
            resy=`echo $res  | cut -d ':' -f 2`
            width=`echo $crop | cut -d ':' -f 1`
            height=`echo $crop | cut -d ':' -f 2`
            ((resy = resy * 720 * height / 576 / width))
            if ((resy / 16 * 16 != resy)); then
                ((resy = (resy / 16 + 1) * 16))
            fi
            res=$resx:$resy
        fi
        scale="scale=$res"
        echo -e "$blue$scale$reset"
    fi
}

# ---------------------------------------------------------------------------- #
# Select crop and scale
# ---------------------------------------------------------------------------- #
selectCropAndScale()
{
    aspect=3
    if [ -z "$res" ]; then
        myRead "aspect :\n (1) 16:9\n (2)  4:3\n (3) no scale\n" 1
        aspect=$ret
    fi
    if [ -z "$crop" ]; then
        if [ $aspect = '1' ]; then
            echo "try mplayer -vf rectangle=720:432:0:72"
            myRead "crop ? (y/n/rectangle)" "y"
        else
            myRead "crop ? (y/n/rectangle)" "n"
        fi
        if [ $ret = n ]; then
            selectScale
            return
        elif [ $ret != y ]; then
            echo "crop=$ret" >>crop.txt
        fi
        if [ ! -r crop.txt ]; then
            myRead "cropdetect ? (y/n)" "y"
            if [ $ret = y ]; then
                detect="-quiet -nosound -vo null -speed 100 -vf cropdetect=24:1"
                detect="$detect -nocache -nozoom -nolirc"
                echo
                if [ $direct = y ]; then
                    if [ $gnu = "true" ]; then
                        mplayer $title $angle $detect 2>/dev/null |\
                          grep "CROP" | tee crop.txt |\
                          sed -n '99~100s/^.*$/\o033[2A/p;100~100='
                    else
                        mplayer $title $angle $detect 2>/dev/null |\
                         grep "CROP" >crop.txt
                    fi
                else
                    if [ $gnu = "true" ]; then
                        cat $list | mplayer $detect - 2>/dev/null |\
                          grep "CROP" | tee crop.txt |\
                          sed -n '99~100s/^.*$/\o033[2A/p;100~100='
                    else
                        cat $list | mplayer $detect - 2>/dev/null |\
                          grep "CROP" >crop.txt
                    fi
                fi
            fi
        fi
        if [ -r crop.txt ]; then
            crop=`tail -n 1 crop.txt | cut -d '=' -f 2 | cut -d ')' -f 1`
        else
            crop=720:576:0:0
        fi
        echo -ne $bel
        myRead "crop ?" $crop
        crop=$ret
    fi
    # Scale
    selectScale
    echo -e "${blue}crop=$crop$reset"
    crop="crop=$crop,"
}

# ---------------------------------------------------------------------------- #
# Select rate
# ---------------------------------------------------------------------------- #
selectRate()
{
    # With 800kbps we can encode a 1h45 DVD on a 700MB CD
    selectTitle
    readLsdvd
    time=`echo $title | awk 'BEGIN { FS="//" } { print $2 }'`
    time=`head -n $time lsdvd.txt | tail -n 1 | cut -c 20-27`
    hour=`echo ${time:0:2} | awk '{ print $0+0 }'`
     min=`echo ${time:3:2} | awk '{ print $0+0 }'`
     sec=`echo ${time:6:2} | awk '{ print $0+0 }'`
    ((time = hour * 3600 + min * 60 + sec))
    ((rate1 = (cdrsize - 5) * 1024 * 1024 / 125 / time - audiobr - marginbr))
    ((rate2 = ((cdrsize - 5) * 2 - splitmarginsize) *\
     1024 * 1024 / 125 / time - audiobr))
    echo -ne "${blue}try $rate1 for ${cdrsize}MB CD,"
    echo -e " $rate2 for 2 x ${cdrsize}MB CD$reset"
    if ((rate2 > 900)); then
        rate2=900
    fi
    if [ -z "$nbcd" ]; then
        if ((rate1 >= ratemin)); then
            myRead "video bitrate ?" $rate1
        else
            myRead "video bitrate ?" $rate2
        fi
    else
        if [ $nbcd = '1' ]; then
            myRead "video bitrate ?" $rate1
        else
            myRead "video bitrate ?" $rate2
        fi
    fi
    rate=$ret
}

# ---------------------------------------------------------------------------- #
# Select audio
# ---------------------------------------------------------------------------- #
selectAudio()
{
    if [ $direct = y ]; then
        return
    fi

    echo -ne "${blue}audio channel"
    echo -e " to be check with mplayer dump.* -aid <id> :$reset"
    aid=0
    if [ -r structure.txt ]; then
        grep "aid" structure.txt
        aid=`grep "aid" structure.txt | grep -m 1 $lang`
        aid=${aid:0-4:3}
        if [ -z "$aid" ]; then
            aid=`grep -m 1 "aid" structure.txt`
            aid=${aid:0-4:3}
        fi
        # Case for the zero value
        aid=`echo "$aid" | cut -d " " -f 2`
    fi
    myRead "audio channel ?" $aid
    aid=$ret
}

# ---------------------------------------------------------------------------- #
# Encode the video
# ---------------------------------------------------------------------------- #
makeVideo()
{
    myRead "pass :\n (1) 1\n (2) 2\n (3) 1&2\n" 3
    pass=$ret
    selectInput
    if [ -z "$name" ]; then
        name=`ls -1 --indicator-style=none *.avi 2>/dev/null |\
          grep -v frameno -m 1`
        if [ $pass != '2' ] || ([ $pass = '2' ] && [ -z "$name" ]); then
            name=video
            echo -e "${blue}current directory :$reset"
            ls
        fi
        myRead "enter a name" $name
        name=$ret
    fi
    ext=${name##*.}
    if [ "$ext" != avi ]; then
        name=${name}.avi
    fi
    if ((pass & 1)); then
        if [ -f $name ]; then
            fatal "$name is already exist !"
        fi
    else
        if [ ! -f divx2pass.log ]; then
            fatal "divx2pass.log do not exist !"
        fi
    fi
    if [ -z "$rate" ]; then
        selectRate
    fi
    # Crop and scale
    selectCropAndScale
    if [ -n "$deinterlace" ] || [ -n "$crop" ] || [ -n "$res" ]; then
        filters="-vf $deinterlace$crop$scale"
    fi
    # Additionnal subtitle
    if [ -z "$sid" ]; then
        grep "sid" structure.txt
        myRead "additionnal subtitle ? (y/n)" "n"
        if [ $ret = y ]; then
            selectSubtitleId
            if [ -z "$sid" ]; then
                myRead "continue ? (y/n)" "y"
                if [ $ret = n ]; then
                    exit 0
                fi
                sid="-nosub"
            fi
        else
            sid="-nosub"
        fi
    fi
    # Audio
    selectAudio
    # Volume
    maximizeVolume
    # Encode
    if [ $direct = y ]; then
        if ((pass & 1)); then
            mencoder $title $angle $filters $sid\
              -ovc lavc -lavcopts vcodec=mpeg4:vpass=1:vbitrate=$rate:$mpeg4opt\
              -oac mp3lame -lameopts cbr:br=$audiobr:vol=$volume:aq=9\
              -alang $lang -ffourcc DIVX -o $name $mencOpt
        fi
        if ((pass & 2)); then
            info="$title $angle $filters $sid vbitrate=$rate:$mpeg4opt"
            info="$info cbr:br=$audiobr:vol=$volume:aq=0 $mencOpt -alang $lang"
            info="%"`expr length "$info"`"%$info"
            mencoder $title $angle $filters $sid\
              -ovc lavc -lavcopts vcodec=mpeg4:vpass=2:vbitrate=$rate:$mpeg4opt\
              -oac mp3lame -lameopts cbr:br=$audiobr:vol=$volume:aq=0\
              -alang $lang -ffourcc DIVX -o $name -info comment="$info" $mencOpt
        fi
    else
        if ((pass & 1)); then
            mencoder $filters $sid\
              -ovc lavc -lavcopts vcodec=mpeg4:vpass=1:vbitrate=$rate:$mpeg4opt\
              -oac mp3lame -lameopts cbr:br=$audiobr:vol=$volume:aq=9 -aid $aid\
              -ffourcc DIVX -o $name $mencOpt $list
        fi
        if ((pass & 2)); then
            info="$filters $sid vbitrate=$rate:$mpeg4opt"
            info="$info cbr:br=$audiobr:vol=$volume:aq=0 $mencOpt -aid $aid"
            info="%"`expr length "$info"`"%$info"
            mencoder $filters $sid\
              -ovc lavc -lavcopts vcodec=mpeg4:vpass=2:vbitrate=$rate:$mpeg4opt\
              -oac mp3lame -lameopts cbr:br=$audiobr:vol=$volume:aq=0 -aid $aid\
              -ffourcc DIVX -o $name -info comment="$info" $mencOpt $list
        fi
    fi
}

# ---------------------------------------------------------------------------- #
# Extract subtitle
# ---------------------------------------------------------------------------- #
extractSubtitle()
{
    # It needs transcode tools :
    # tcextract, subtitle2pgm, pgm2txt, srttool
    if [ $direct = y ]; then
        fatal "sorry, you must rip the DVD"
    fi
    selectInput
    grep "sid" structure.txt
    selectSubtitleId
    if [ -z "$sid" ]; then
        fatal
    fi
    echo -e "${blue}please wait...$reset"
    sid=0x2$ret
    cat $list | ${tcpath}/import/tcextract -x ps1 -t vob -a $sid >subs
    echo -ne $bel
    myRead "language ?" "francais"
    lang=$ret
    ${tcpath}/contrib/subrip/subtitle2pgm -o $lang -c $subgreylevels < subs
    ${tcpath}/contrib/subrip/pgm2txt $lang
    myRead "check spelling ? (y/n)" "n"
    if [ $ret = y ]; then
        ispell -d $lang $lang*txt
    fi
    ${tcpath}/contrib/subrip/srttool -s -w < $lang.srtx >$lang.srt
}

# ---------------------------------------------------------------------------- #
# Extract wav
# ---------------------------------------------------------------------------- #
extractWav()
{
    selectInput
    myRead "number of files :\n (1) one per chapter\n (2) only one\n" "1"
    if [ $ret = 1 ]; then
        if [ $direct = y ]; then
            selectChapters
        else
            selectAudio
        fi
        for ((i = first; i <= last; ++i)); do
            n=`printf %02d $i`
            if [ $direct = y ]; then
                mplayer $title $angle -chapter $i-$i\
                  -vo null -ao pcm:file=audio_$n.wav
            else
                mplayer dump.$n -vo null -aid $aid -ao pcm:file=audio_$n.wav
            fi
        done
    else
        if [ $direct = y ]; then
            mplayer $title $angle -vo null -ao pcm:file=audio.wav
        else
            selectAudio
            cat $list | mplayer -vo null -aid $aid -ao pcm:file=audio.wav -
        fi
    fi
}

# ---------------------------------------------------------------------------- #
# Check a numeric value
# ---------------------------------------------------------------------------- #
checkNumericValue()
{
    if [ -n "`echo $1 | grep [^0-9,]`" ] ||\
      ([ -n "$3" ] && (($1 < $3))) ||\
      ([ -n "$4" ] && (($1 > $4))); then
        fatal "bad value for: $2"
    fi
}

# ---------------------------------------------------------------------------- #
# Read options
# ---------------------------------------------------------------------------- #
readOptions()
{
    # Initialize some variables set by options.
    dir=
    auto=no
    sid=
    subgreylevels=255,255,0,255
    title=
    angle=
    first=
    last=
    normalize=false
    nbcd=
    crop=
    subtitle=no
    split=no
    ipod=no
    res=
    rate=
    audiobr=128
    volume=1
    wav=no
    deinterlace=
    dev=
    cdrsize=700
    verbose=no
    bel="\a"
    mencOpt=

    ac_prev=
    for ac_option
    do
        # If the previous option needs an argument, assign it.
        if [ -n "$ac_prev" ]; then
            case "$ac_prev" in
                rate)
                    checkNumericValue $ac_option "$ac_prev" 4 24000000 ;;
                audiobr)
                    checkNumericValue $ac_option "$ac_prev" 32 320 ;;
                title | angle | first)
                    checkNumericValue $ac_option "$ac_prev" 1 ;;
                nbcd)
                    checkNumericValue $ac_option "$ac_prev" 1 2 ;;
                cdrsize)
                    checkNumericValue $ac_option "$ac_prev" 0 2048 ;;
            esac
            if [ "$ac_prev" != "--" ]; then
                eval "$ac_prev=\$ac_option"
                ac_prev=
            else
                mencOpt="$mencOpt $ac_option"
            fi
            continue
        fi

        case "$ac_option" in
            -d | -dir | --dir)
                ac_prev=dir ;;
            -d=* | -dir=* | --dir=*)
                dir=`echo $ac_option | cut -d '=' -f 2` ;;
            -A | -auto | --auto)
                auto=yes
                bel=
                ;;
            -f | -sid | --sid)
                ac_prev=sid ;;
            -f=* | -sid=* | --sid=*)
                sid=`echo $ac_option | cut -d '=' -f 2` ;;
            -g | -subgreylevels | --subgreylevels)
                ac_prev=subgreylevels ;;
            -g=* | -subgreylevels=* | --subgreylevels=*)
                subgreylevels=`echo $ac_option | cut -d '=' -f 2` ;;
            -l | -crop | --crop)
                ac_prev=crop ;;
            -l=* | -crop=* | --crop=*)
                crop=`echo $ac_option | cut -d '=' -f 2` ;;
            -T | -chapter | --chapter)
                ac_prev=first ;;
            -T=* | -chapter=* | --chapter=*)
                first=`echo $ac_option | cut -d '=' -f 2`
                last=$first
                checkNumericValue $first "chapter" 1
                ;;
            -t | -title | --title)
                ac_prev=title ;;
            -t=* | -title=* | --title=*)
                title=`echo $ac_option | cut -d '=' -f 2`
                checkNumericValue $title "titre" 1
                ;;
            -a | -angle | --angle)
                ac_prev=angle ;;
            -a=* | -angle=* | --angle=*)
                angle=`echo $ac_option | cut -d '=' -f 2`
                checkNumericValue $angle "angle" 1
                ;;
            -n | -normalize | --normalize)
                normalize=true ;;
            -N | -nbcd | --nbcd)
                ac_prev=nbcd ;;
            -N=* | -nbcd=* | --nbcd=*)
                angle=`echo $ac_option | cut -d '=' -f 2`
                checkNumericValue $nbcd "nbcd" 1 2
                ;;
            -D | -deinterlace | --deinterlace)
                deinterlace="pp=fd," ;;
            -s | -subtitle | --subtitle)
                subtitle=yes ;;
            -S | -split | --split)
                split=yes ;;
            -p | -ipod | --ipod)
                ipod=yes ;;
            -r | -res | --res)
                ac_prev=res ;;
            -r=* | -res=* | --res=*)
                res=`echo $ac_option | cut -d '=' -f 2`
                ;;
            -B | -videobr | --videobr)
                ac_prev=rate ;;
            -B=* | -videobr=* | --videobr=*)
                rate=`echo $ac_option | cut -d '=' -f 2`
                checkNumericValue $rate "videobr" 4 24000000
                ;;
            -b | -audiobr | --audiobr)
                ac_prev=audiobr ;;
            -b=* | -audiobr=* | --audiobr=*)
                audiobr=`echo $ac_option | cut -d '=' -f 2`
                checkNumericValue $audiobr "audiobr" 32 320
                ;;
            -V | -vol | --vol)
                ac_prev=volume ;;
            -V=* | -vol=* | --vol=*)
                volume=`echo $ac_option | cut -d '=' -f 2` ;;
            -w | -wav | --wav)
                wav=yes ;;
            -i | -dev | --dev)
                ac_prev=dev ;;
            -i=* | -dev=* | --dev=*)
                dev=`echo $ac_option | cut -d '=' -f 2` ;;
            -c | -nocolors | --nocolors)
                red=
                green=
                blue=
                reset=
                ;;
            -C | -cdrsize | --cdrsize)
                ac_prev=cdrsize ;;
            -C=* | -cdrsize=* | --cdrsize=*)
                cdrsize=`echo $ac_option | cut -d '=' -f 2`
                checkNumericValue $cdrsize "cdrsize" 0 2048
                ;;
            -v | -verbose | --verbose)
                verbose=yes ;;
            -h | -help | --help)
                this=${0##*/}
                cat << EOF

$this is a shell script to rip DVD and encode to DIVX
It can :
 - rip, encode audio, encode video, separately into different sessions
 - crop the black bars with autodetection
 - choose the best resolution for the 16:9 or 4:3 format
 - maximize volume (with a mencoder patch)
 - extract subtitle into a separated text file (with transcode tools)
 - split the AVI
The video bitrate is a bit different from the mencoder recommendation, it's
for a maximum filling for one CD, or to leave a margin to split the AVI.

Usage: $this [options]
Options:
  -A, --auto                 use automatic values
  -a, --angle=N              set angle
  -B, --videobr=<4-24000000> set video bitrate
  -b, --audiobr=<32-320>     change audio bitrate for lame [$audiobr]
  -C, --cdrsize=SIZE         change the size of a CD [$cdrsize]
  -c, --nocolors             do not use colors
  -D, --deinterlace          use deinterlace filter
  -d, --dir=DIR              change directory [./]
  -f, --sid=FILE|0-31        set subtitle file or sid
  -g, --subgreylevels=LEVEL  set subgrey levels [$subgreylevels]
  -h, --help                 print this help message
  -i, --dev=DEV              change dvd device [/dev/dvd]
  -l, --crop=CROP            set crop (ex: 720:576:0:0)
  -N, --nbcd=<1-2>           set number of CD
  -n, --normalize            use normalize to maximize volume
  -p, --ipod                 make an ipod video
  -r, --res=XXX:YYY          set resolution
  -S, --split                split AVI
  -s, --subtitle             extract text subtitle
  -T, --chapter=N            set chapter
  -t, --title=N              set title
  -V, --vol=<0-10>           change audio input gain for lame [$volume]
  -w, --wav                  extract audio to wav file(s)
  --                         options passed to mencoder (ex: -- -ni)

For more info type : vi $this

EOF
                exit 0 ;;
            --)
                ac_prev=-- ;;
            *)
                fatal "unknown parameter: $ac_option" ;;
        esac
    done

    if [ -n "$ac_prev" ] && [ "$ac_prev" != "--" ]; then
        fatal "bad value for: $ac_prev"
    fi

    if [ -n "$sid" ]; then
        if [ -f $sid ]; then
            sid="-sub $sid -subfont-text-scale 3"
        else
            sid="-sid $sid"
        fi
    fi
    if [ -n "$dir" ]; then
        if [ ! -d $dir ]; then
            myRead "$dir does not exist, create it ? (y/n)" y
            if [ $ret = y ]; then
                mkdir -p $dir
                cd $dir
            fi
        else
            cd $dir
        fi
    fi
    if [ -n "$title" ]; then
        title=dvd://$title
    fi
    if [ -n "$angle" ]; then
        angle="-dvdangle $angle"
    fi
    if [ -n "$first" ]; then
        last=$first
    fi
}

# ---------------------------------------------------------------------------- #
# splitAVI
# ---------------------------------------------------------------------------- #
splitAVI()
{
    if [ -f frameno.avi ]; then
        mv frameno.avi frameno.avi.sav
    fi
    name=`ls -1 --indicator-style=none *.avi 2>/dev/null | tail -n 1`
    myRead "avi to split ?" $name
    name=$ret
    n0=`mplayer "$name" -v -frames 0 2>/dev/null | grep "frames  total" |\
        awk '{ print $3 }'`
    if [ -z "$n0" ]; then
        myRead "frames total ?"
        n0=$ret
    fi
    ret=n
    while [ $ret = n ]; do
        myRead "offset (secondes) ?" -60
        offset=$ret
        ((time = n0 / 50 + offset))
        echo $n0
        echo -e "${blue}press return to start playing,"
        echo -e "then press escape where to split$reset"
        read ret
        mplayer "$name" -vf framestep=I -ss $time -nofs -xy 1 2>/dev/null |\
          grep "ct:" | tee keyframes.txt
        frame=`tail -n 1 keyframes.txt | cut -d "/" -f 2 | cut -d " " -f 1`
        myRead "frame=$frame (y/n)" y
    done
    name=`echo "$name" | sed 's/\.avi//'`
    info=`mplayer -novideo -nosound -v $name.avi 2>/dev/null |\
      grep "Comments  :" | sed "s/Comments  ://"`
    info="%"`expr length "$info"`"%$info"
    mencoder "$name.avi" -ovc copy -oac copy -frames $((frame - 1))\
      -o "${name}_1.avi" -info comment="split $info" $mencOpt
    time=`echo $frame | awk '{ print $0/25 }'`
    mencoder "$name.avi" -ovc copy -oac copy -ss $time\
      -o "${name}_2.avi" -info comment="split $info" $mencOpt
    n1=`mplayer "${name}_1.avi" -v -frames 0 2>/dev/null |\
        grep "frames  total" | awk '{ print $3 }'`
    n2=`mplayer "${name}_2.avi" -v -frames 0 2>/dev/null |\
        grep "frames  total" | awk '{ print $3 }'`
    echo "${name}_1.avi: $n1 frames"
    echo "${name}_2.avi: $n2 frames"
    echo "$((n1 + n2))/$n0 frames"
}

# ---------------------------------------------------------------------------- #
# makeIpod
# ---------------------------------------------------------------------------- #
makeIpod()
{
    if [ $direct = y ]; then
        fatal "sorry, you must rip the DVD"
    fi
    selectInput
    selectAudio
    for ((i = first; i <= last; ++i)); do
        num=`printf %02d $i`
        file=dump.$num
        mencoder $file -aid $aid -oac pcm -ovc copy -o dump.tmp $mencOpt
        if [ -r titles.txt ]; then
            title=`head -n $i titles.txt | tail -n 1`
            title=" - $title"
        fi
        ffmpeg -f dvd -i dump.tmp -f mp4 -vcodec mpeg4 -maxrate 1000\
          -b 700 -qmin 3 -qmax 5 -bufsize 4096 -g 300 -acodec libfaac\
          -ab 192 -s 320x180 -aspect 16:9 "$num$title.mov"
    done
    rm -f dump.tmp
}

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
readOptions $*
if [ $split = yes ]; then
    splitAVI
    exit 0
fi
if [ -r structure.txt ]; then
    echo -e "${blue}warning : structure.txt exist, it will be used$reset"
fi
dir=`pwd`
size=`df -Pk "$dir" | tail -n 1 | awk 'BEGIN { FS = " " } { print $4 }'`
echo -e "${blue}disk space left in $dir : $size Kbytes$reset"
myRead "continue ? (y/n)" "y"
if [ $ret = n ]; then
    exit 0
fi
if [ -f dump.01 ]; then
    myRead "rip the DVD ? (y/n)" "n"
else
    myRead "rip the DVD ? (y/n)" "y"
fi
if [ $ret = y ]; then
    makeDump
    direct=n
else
    myRead "encode directly from the DVD ? (y/n)" "n"
    direct=$ret
fi
if [ $subtitle = yes ]; then
    extractSubtitle
    exit 0
fi
if [ $wav = yes ]; then
    extractWav
    exit 0
fi
if [ $ipod = yes ]; then
    makeIpod
    exit 0
fi
myRead "encode video ? (y/n)" "y"
if [ $ret = y ]; then
    makeVideo
fi
echo -ne "\a"
