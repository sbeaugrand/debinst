#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file vacances.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
year=$1
format=$2
zone=$3

if [ "$year" = "2022" ]; then
    vAsmZoneB=01; vAsdZoneB=01; vAemZoneB=01; vAedZoneB=02;
    vAsmZoneA=01; vAsdZoneA=01; vAemZoneA=01; vAedZoneA=02;
    vAsmZoneC=01; vAsdZoneC=01; vAemZoneC=01; vAedZoneC=02;

    vBsmZoneB=02; vBsdZoneB=06; vBemZoneB=02; vBedZoneB=20;
    vBsmZoneA=02; vBsdZoneA=13; vBemZoneA=02; vBedZoneA=27;
    vBsmZoneC=02; vBsdZoneC=20; vBemZoneC=03; vBedZoneC=06;

    vCsmZoneB=04; vCsdZoneB=10; vCemZoneB=04; vCedZoneB=24;
    vCsmZoneA=04; vCsdZoneA=17; vCemZoneA=05; vCedZoneA=01;
    vCsmZoneC=04; vCsdZoneC=24; vCemZoneC=05; vCedZoneC=08;

    vDsmZoneA=07; vDsdZoneA=07; vDemZoneA=08; vDedZoneA=31;
    vDsmZoneB=07; vDsdZoneB=07; vDemZoneB=08; vDedZoneB=31;
    vDsmZoneC=07; vDsdZoneC=07; vDemZoneC=08; vDedZoneC=31;

    vEsmZoneB=10; vEsdZoneB=23; vEemZoneB=11; vEedZoneB=06;
    vEsmZoneA=10; vEsdZoneA=23; vEemZoneA=11; vEedZoneA=06;
    vEsmZoneC=10; vEsdZoneC=23; vEemZoneC=11; vEedZoneC=06;

    vFsmZoneC=12; vFsdZoneC=18; vFemZoneC=12; vFedZoneC=31;
    vFsmZoneB=12; vFsdZoneB=18; vFemZoneB=12; vFedZoneB=31;
    vFsmZoneA=12; vFsdZoneA=18; vFemZoneA=12; vFedZoneA=31;
elif [ "$year" = "2023" ]; then
    vAsmZoneC=01; vAsdZoneC=01; vAemZoneC=01; vAedZoneC=02;
    vAsmZoneB=01; vAsdZoneB=01; vAemZoneB=01; vAedZoneB=02;
    vAsmZoneA=01; vAsdZoneA=01; vAemZoneA=01; vAedZoneA=02;

    vBsmZoneA=02; vBsdZoneA=05; vBemZoneA=02; vBedZoneA=19;
    vBsmZoneB=02; vBsdZoneB=12; vBemZoneB=02; vBedZoneB=26;
    vBsmZoneC=02; vBsdZoneC=19; vBemZoneC=03; vBedZoneC=05;

    vCsmZoneA=04; vCsdZoneA=09; vCemZoneA=04; vCedZoneA=23;
    vCsmZoneB=04; vCsdZoneB=16; vCemZoneB=05; vCedZoneB=01;
    vCsmZoneC=04; vCsdZoneC=23; vCemZoneC=05; vCedZoneC=08;

    vDsmZoneC=07; vDsdZoneC=09; vDemZoneC=09; vDedZoneC=03;
    vDsmZoneA=07; vDsdZoneA=09; vDemZoneA=09; vDedZoneA=03;
    vDsmZoneB=07; vDsdZoneB=09; vDemZoneB=09; vDedZoneB=03;

    vEsmZoneA=10; vEsdZoneA=22; vEemZoneA=11; vEedZoneA=05;
    vEsmZoneB=10; vEsdZoneB=22; vEemZoneB=11; vEedZoneB=05;
    vEsmZoneC=10; vEsdZoneC=22; vEemZoneC=11; vEedZoneC=05;

    vFsmZoneA=12; vFsdZoneA=24; vFemZoneA=12; vFedZoneA=31;
    vFsmZoneC=12; vFsdZoneC=24; vFemZoneC=12; vFedZoneC=31;
    vFsmZoneB=12; vFsdZoneB=24; vFemZoneB=12; vFedZoneB=31;
elif ((`cat /proc/net/arp | wc -l` < 2)); then
    exit 1
else
    file=vacances$year.json
    if [ ! -f $file ]; then
        curl -s -o $file "https://data.education.gouv.fr/api/records/1.0/search/?dataset=fr-en-calendrier-scolaire&q=(start_date%3A$year+OR+end_date%3A$year)+AND+(location%3ALyon+OR+location%3ANice+OR+location%3AParis)&rows=18&sort=-end_date&exclude.description=Pont+de+l%27Ascension&exclude.population=Enseignants"
    fi
    file=build/vacances$year.sh
    ./vacances.py $year >$file || exit 1
    source $file
fi

if [ "$format" = "tex" ]; then
    cat <<EOF
\def\vAsdZoneA{$vAsdZoneA} \def\vAsmZoneA{$vAsmZoneA} \
\def\vAedZoneA{$vAedZoneA} \def\vAemZoneA{$vAemZoneA}

\def\vBsdZoneA{$vBsdZoneA} \def\vBsmZoneA{$vBsmZoneA} \
\def\vBedZoneA{$vBedZoneA} \def\vBemZoneA{$vBemZoneA}
\def\vBsdZoneB{$vBsdZoneB} \def\vBsmZoneB{$vBsmZoneB} \
\def\vBedZoneB{$vBedZoneB} \def\vBemZoneB{$vBemZoneB}
\def\vBsdZoneC{$vBsdZoneC} \def\vBsmZoneC{$vBsmZoneC} \
\def\vBedZoneC{$vBedZoneC} \def\vBemZoneC{$vBemZoneC}

\def\vCsdZoneA{$vCsdZoneA} \def\vCsmZoneA{$vCsmZoneA} \
\def\vCedZoneA{$vCedZoneA} \def\vCemZoneA{$vCemZoneA}
\def\vCsdZoneB{$vCsdZoneB} \def\vCsmZoneB{$vCsmZoneB} \
\def\vCedZoneB{$vCedZoneB} \def\vCemZoneB{$vCemZoneB}
\def\vCsdZoneC{$vCsdZoneC} \def\vCsmZoneC{$vCsmZoneC} \
\def\vCedZoneC{$vCedZoneC} \def\vCemZoneC{$vCemZoneC}

\def\vDsdZoneA{$vDsdZoneA} \def\vDsmZoneA{$vDsmZoneA} \
\def\vDedZoneA{$vDedZoneA} \def\vDemZoneA{$vDemZoneA}

\def\vEsdZoneA{$vEsdZoneA} \def\vEsmZoneA{$vEsmZoneA} \
\def\vEedZoneA{$vEedZoneA} \def\vEemZoneA{$vEemZoneA}

\def\vFsdZoneA{$vFsdZoneA} \def\vFsmZoneA{$vFsmZoneA} \
\def\vFedZoneA{$vFedZoneA} \def\vFemZoneA{$vFemZoneA}
EOF
elif [ "$format" = "janvier" ]; then
    echo "$vAsdZoneA $vAsmZoneA $vAedZoneA $vAemZoneA"
elif [ "$format" = "hiver" ]; then
    if [ "$zone" = A ]; then
        echo "$vBsdZoneA $vBsmZoneA $vBedZoneA $vBemZoneA"
    elif [ "$zone" = B ]; then
        echo "$vBsdZoneB $vBsmZoneB $vBedZoneB $vBemZoneB"
    else
        echo "$vBsdZoneC $vBsmZoneC $vBedZoneC $vBemZoneC"
    fi
elif [ "$format" = "printemps" ]; then
    if [ "$zone" = A ]; then
        echo "$vCsdZoneA $vCsmZoneA $vCedZoneA $vCemZoneA"
    elif [ "$zone" = B ]; then
        echo "$vCsdZoneB $vCsmZoneB $vCedZoneB $vCemZoneB"
    else
        echo "$vCsdZoneC $vCsmZoneC $vCedZoneC $vCemZoneC"
    fi
elif [ "$format" = "ete" ]; then
    echo "$vDsdZoneA $vDsmZoneA $vDedZoneA $vDemZoneA"
elif [ "$format" = "toussaint" ]; then
    echo "$vEsdZoneA $vEsmZoneA $vEedZoneA $vEemZoneA"
elif [ "$format" = "noel" ]; then
    echo "$vFsdZoneA $vFsmZoneA $vFedZoneA $vFemZoneA"
fi
