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

if [ "$year" = "2026" ]; then
    vAsmZoneB=01; vAsdZoneB=01; vAemZoneB=01; vAedZoneB=04;
    vAsmZoneC=01; vAsdZoneC=01; vAemZoneC=01; vAedZoneC=04;
    vAsmZoneA=01; vAsdZoneA=01; vAemZoneA=01; vAedZoneA=04;

    vBsmZoneA=02; vBsdZoneA=08; vBemZoneA=02; vBedZoneA=22;
    vBsmZoneB=02; vBsdZoneB=15; vBemZoneB=03; vBedZoneB=01;
    vBsmZoneC=02; vBsdZoneC=22; vBemZoneC=03; vBedZoneC=08;

    vCsmZoneA=04; vCsdZoneA=05; vCemZoneA=04; vCedZoneA=19;
    vCsmZoneB=04; vCsdZoneB=12; vCemZoneB=04; vCedZoneB=26;
    vCsmZoneC=04; vCsdZoneC=19; vCemZoneC=05; vCedZoneC=03;

    vDsmZoneA=07; vDsdZoneA=05; vDemZoneA=08; vDedZoneA=31;
    vDsmZoneC=07; vDsdZoneC=05; vDemZoneC=08; vDedZoneC=31;
    vDsmZoneB=07; vDsdZoneB=05; vDemZoneB=08; vDedZoneB=31;

    vEsmZoneC=10; vEsdZoneC=18; vEemZoneC=11; vEedZoneC=01;
    vEsmZoneB=10; vEsdZoneB=18; vEemZoneB=11; vEedZoneB=01;
    vEsmZoneA=10; vEsdZoneA=18; vEemZoneA=11; vEedZoneA=01;

    vFsmZoneA=12; vFsdZoneA=20; vFemZoneA=12; vFedZoneA=31;
    vFsmZoneC=12; vFsdZoneC=20; vFemZoneC=12; vFedZoneC=31;
    vFsmZoneB=12; vFsdZoneB=20; vFemZoneB=12; vFedZoneB=31;
elif [ "$year" = "2027" ]; then
    vAsmZoneA=01; vAsdZoneA=01; vAemZoneA=01; vAedZoneA=03;
    vAsmZoneC=01; vAsdZoneC=01; vAemZoneC=01; vAedZoneC=03;
    vAsmZoneB=01; vAsdZoneB=01; vAemZoneB=01; vAedZoneB=03;

    vBsmZoneC=02; vBsdZoneC=07; vBemZoneC=02; vBedZoneC=21;
    vBsmZoneA=02; vBsdZoneA=14; vBemZoneA=02; vBedZoneA=28;
    vBsmZoneB=02; vBsdZoneB=21; vBemZoneB=03; vBedZoneB=07;

    vCsmZoneC=04; vCsdZoneC=04; vCemZoneC=04; vCedZoneC=18;
    vCsmZoneA=04; vCsdZoneA=11; vCemZoneA=04; vCedZoneA=25;
    vCsmZoneB=04; vCsdZoneB=18; vCemZoneB=05; vCedZoneB=02;

    vDsmZoneB=07; vDsdZoneB=04; vDemZoneB=09; vDedZoneB=01;
    vDsmZoneC=07; vDsdZoneC=04; vDemZoneC=09; vDedZoneC=01;
    vDsmZoneA=07; vDsdZoneA=04; vDemZoneA=09; vDedZoneA=01;

    vEsmZoneA=10; vEsdZoneA=24; vEemZoneA=11; vEedZoneA=07;
    vEsmZoneB=10; vEsdZoneB=24; vEemZoneB=11; vEedZoneB=07;
    vEsmZoneC=10; vEsdZoneC=24; vEemZoneC=11; vEedZoneC=07;

    vFsmZoneB=12; vFsdZoneB=19; vFemZoneB=12; vFedZoneB=31;
    vFsmZoneC=12; vFsdZoneC=19; vFemZoneC=12; vFedZoneC=31;
    vFsmZoneA=12; vFsdZoneA=19; vFemZoneA=12; vFedZoneA=31;
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
