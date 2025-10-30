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
elif [ "$year" = "2025" ]; then
    vAsmZoneA=01; vAsdZoneA=01; vAemZoneA=01; vAedZoneA=05;
    vAsmZoneC=01; vAsdZoneC=01; vAemZoneC=01; vAedZoneC=05;
    vAsmZoneB=01; vAsdZoneB=01; vAemZoneB=01; vAedZoneB=05;

    vBsmZoneB=02; vBsdZoneB=09; vBemZoneB=02; vBedZoneB=23;
    vBsmZoneC=02; vBsdZoneC=16; vBemZoneC=03; vBedZoneC=02;
    vBsmZoneA=02; vBsdZoneA=23; vBemZoneA=03; vBedZoneA=09;

    vCsmZoneB=04; vCsdZoneB=06; vCemZoneB=04; vCedZoneB=21;
    vCsmZoneC=04; vCsdZoneC=13; vCemZoneC=04; vCedZoneC=27;
    vCsmZoneA=04; vCsdZoneA=20; vCemZoneA=05; vCedZoneA=04;

    vDsmZoneA=07; vDsdZoneA=06; vDemZoneA=08; vDedZoneA=31;
    vDsmZoneB=07; vDsdZoneB=06; vDemZoneB=08; vDedZoneB=31;
    vDsmZoneC=07; vDsdZoneC=06; vDemZoneC=08; vDedZoneC=31;

    vEsmZoneA=10; vEsdZoneA=19; vEemZoneA=11; vEedZoneA=02;
    vEsmZoneB=10; vEsdZoneB=19; vEemZoneB=11; vEedZoneB=02;
    vEsmZoneC=10; vEsdZoneC=19; vEemZoneC=11; vEedZoneC=02;

    vFsmZoneB=12; vFsdZoneB=21; vFemZoneB=12; vFedZoneB=31;
    vFsmZoneA=12; vFsdZoneA=21; vFemZoneA=12; vFedZoneA=31;
    vFsmZoneC=12; vFsdZoneC=21; vFemZoneC=12; vFedZoneC=31;
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
