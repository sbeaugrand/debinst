#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file volet-at.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Test: ipath=~/install/debinst ./volet-at.sh -t
# ---------------------------------------------------------------------------- #
year=`date +%Y`
zone=C
[ -z "$ipath" ] && ipath=/home/pi/install/debinst
[ -z "$cpath" ] && cpath=$ipath/install-14-cal
[ -z "$vpath" ] && vpath=$ipath/install-op-rpi/install-op-volet

# ---------------------------------------------------------------------------- #
## \fn nearVacation
# ---------------------------------------------------------------------------- #
nearVacation()
{
    if [ -z "$2" ]; then
        if [ -z "$1" ]; then
            return 1
        fi
        s0=`LANG=C date +%a`
        s1="$1"
        s2=`LANG=C date -d "+1 day" +%a`
        if ([ $s2 = $s1 ] && ((heure >= heure2))) || \
            ([ $s0 = $s1 ] && ((heure < heure2))); then
            echo "vacances $*"
            return 0
        else
            return 1
        fi
    else
        s0=`date -d "$heure2:00 $2/$1/$year -1 day" +%s`
        s1=`date +%s`
        if [ -z "$3" ]; then
            s2=`date -d "$heure2:00 $2/$1/$year" +%s`
            if [ $1 = "01" ] && [ $2 = "01" ]; then
                jour=`date +%d`
                mois=`date +%m`
                if [ $jour = "31" ] && [ $mois = "12" ]; then
                    ((y2 = year + 1))
                    s0=`date -d "$heure2:00 12/31/$year" +%s`
                    s2=`date -d "$heure2:00 01/01/$y2" +%s`
                fi
            fi
        else
            s2=`date -d "$heure2:00 $4/$3/$year" +%s`
        fi
        if ((s1 >= s0)) && ((s1 < s2)); then
            echo "vacances $*"
            return 0
        else
            return 1
        fi
    fi
}

# ---------------------------------------------------------------------------- #
## \fn vacation
# ---------------------------------------------------------------------------- #
vacation()
{
    source paques.sh
    paques $year lundi
    ascension
    pentecote
    echo "Lundi de paques $D/$M/$year"
    echo "Jeudi de l'ascension $AD/$AM/$year"
    echo "Lundi de pentecote $PD/$PM/$year"
    echo "heure=$heure heure2=$heure2"
    if nearVacation "Sat" || \
        nearVacation "Sun" || \
        nearVacation "Wed" || \
        nearVacation 01 01 || \
        nearVacation $D $M || \
        nearVacation $AD $AM || \
        nearVacation $PD $PM || \
        nearVacation 01 05 || \
        nearVacation 08 05 || \
        nearVacation 14 07 || \
        nearVacation 15 08 || \
        nearVacation 01 11 || \
        nearVacation 11 11 || \
        nearVacation 25 12 || \
        nearVacation `./vacances.sh $year janvier` || \
        nearVacation `./vacances.sh $year hiver $zone` || \
        nearVacation `./vacances.sh $year printemps $zone` || \
        nearVacation `./vacances.sh $year ete` || \
        nearVacation `./vacances.sh $year toussaint` || \
        nearVacation `./vacances.sh $year noel`; then
        return 0
    else
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
echo "-------------------------------------------------------------------------"
cd $cpath
heure=`date +%H | awk '{ print $1 + 0 }'`
ls -l build/sun
if [ -f build/sun ]; then
    file=config-pr-symlink.mk
    if  [ -f $file ]; then
        lat=`cat $file | grep LAT | awk '{ print $3 }'`
        lon=`cat $file | grep LON | awk '{ print $3 }'`
        h0=`cat $file | grep H0 | awk '{ print $3 }'`
    fi
    file=config.mk
    if [ -z "$lat" ]; then
        lat=`cat $file | grep LAT | awk '{ print $3 }'`
    fi
    if [ -z "$lon" ]; then
        lon=`cat $file | grep LON | awk '{ print $3 }'`
    fi
    if [ -z "$h0" ]; then
        h0=`cat $file | grep H0 | awk '{ print $3 }'`
    fi
    date=`date +%Y-%m-%d`
    sun=`build/sun $date $lat $lon $h0`
    echo "build/sun $date $lat $lon $h0"
    echo "$sun"
    heure2=`echo $sun | cut -d ' ' -f 3 | cut -d ':' -f 1`
    mod2=1
    min2=`echo $sun | cut -d ' ' -f 3 | cut -d ':' -f 2`
    if ((heure >= heure2)); then
        date=`date -d "+1 day" +%Y-%m-%d`
        sun=`build/sun $date $lat $lon $h0`
        echo "build/sun $date $lat $lon $h0"
        echo "$sun"
    fi
    heure1=`echo $sun | cut -d ' ' -f 1 | cut -d ':' -f 1`
    mod1=1
    min1=`echo $sun | cut -d ' ' -f 1 | cut -d ':' -f 2`
    heure1=`echo $heure1 | awk '{ print $1 + 0 }'`
    m1=`echo $min1 | awk '{ print $1 + 0 }'`
    if ((heure1 < 7)) || (((heure1 == 7)) && ((m1 < 30))); then
        heure1=7
        min1=30
    fi
else
    heure1=8
    mod1=1
    min1=0
    heure2=21
    mod2=30
    min2=15
fi
if vacation; then
    heure1=8
    mod1=30
    min1=30
fi

if [ "$1" = "haut" ]; then
    pos=haut
    shift
elif [ "$1" = "bas" ]; then
    pos=bas
    shift
elif ((heure >= heure1)) && ((heure < heure2)); then
    pos=bas
else
    pos=haut
fi

if [ $pos == "haut" ]; then
    hh=`echo $heure1 | awk '{ printf "%02d\n", $1 }'`
    mm=`echo $RANDOM | awk '{ printf "%02d\n", ($1 % '$mod1') + '$min1' }'`
else
    hh=`echo $heure2 | awk '{ printf "%02d\n", $1 }'`
    mm=`echo $RANDOM | awk '{ printf "%02d\n", ($1 % '$mod2') + '$min2' }'`
fi

echo "$heure $pos $hh:$mm"

if [ "$1" = "-t" ]; then
    exit 0
fi

# ---------------------------------------------------------------------------- #
# /etc/init.d/atd start
# ---------------------------------------------------------------------------- #
dir=/run/cron
file=$dir/atjobs/.SEQ
if [ ! -f $file ]; then
    sudo mkdir -p $dir/atjobs
    sudo mkdir -p $dir/atspool
    echo 0 | sudo tee $file >/dev/null
    sudo chown -R daemon.daemon $dir
    sudo chmod -R 770 $dir
    sudo /etc/init.d/atd start
fi

# ---------------------------------------------------------------------------- #
# at
# ---------------------------------------------------------------------------- #
log=/run/volet.log
[ -f $log ] || sudo touch $log

cd $vpath
echo "
date | sudo tee -a $log
sudo ./volet.sh $pos 2>&1 | sudo tee -a $log
sleep 10
sudo ./volet.sh $pos 2>&1 | sudo tee -a $log
./volet-at.sh 2>&1 | sudo tee -a $log
" | at -M $hh:$mm
echo "-------------------------------------------------------------------------"
