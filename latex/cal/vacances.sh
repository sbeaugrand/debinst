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
    vOOIddOOI=01; vOOIdmOOI=01; vOOIfdOOI=02; vOOIfmOOI=01;

    vOIIddOOI=13; vOIIdmOOI=02; vOIIfdOOI=27; vOIIfmOOI=02;
    vOIIddOII=06; vOIIdmOII=02; vOIIfdOII=20; vOIIfmOII=02;
    vOIIddIII=20; vOIIdmIII=02; vOIIfdIII=06; vOIIfmIII=03;

    vIIIddOOI=17; vIIIdmOOI=04; vIIIfdOOI=01; vIIIfmOOI=05;
    vIIIddOII=10; vIIIdmOII=04; vIIIfdOII=24; vIIIfmOII=04;
    vIIIddIII=24; vIIIdmIII=04; vIIIfdIII=08; vIIIfmIII=05;

    vOIVddOOI=08; vOIVdmOOI=07; vOIVfdOOI=31; vOIVfmOOI=08;

    vOOVddOOI=23; vOOVdmOOI=10; vOOVfdOOI=06; vOOVfmOOI=11;

    vOVIddOOI=18; vOVIdmOOI=12; vOVIfdOOI=31; vOVIfmOOI=12;
elif [ "$year" = "2023" ]; then
    vOOIddOOI=01; vOOIdmOOI=01; vOOIfdOOI=02; vOOIfmOOI=01;

    vOIIddOOI=05; vOIIdmOOI=02; vOIIfdOOI=19; vOIIfmOOI=02;
    vOIIddOII=12; vOIIdmOII=02; vOIIfdOII=26; vOIIfmOII=02;
    vOIIddIII=19; vOIIdmIII=02; vOIIfdIII=05; vOIIfmIII=03;

    vIIIddOOI=09; vIIIdmOOI=04; vIIIfdOOI=23; vIIIfmOOI=04;
    vIIIddOII=16; vIIIdmOII=04; vIIIfdOII=30; vIIIfmOII=04;
    vIIIddIII=23; vIIIdmIII=04; vIIIfdIII=07; vIIIfmIII=05;

    vOIVddOOI=09; vOIVdmOOI=07; vOIVfdOOI=03; vOIVfmOOI=09;

    vOOVddOOI=22; vOOVdmOOI=10; vOOVfdOOI=05; vOOVfmOOI=11;

    vOVIddOOI=24; vOVIdmOOI=12; vOVIfdOOI=31; vOVIfmOOI=12;
fi

if [ "$format" = "tex" ]; then
    cat <<EOF
\def\vOOIddOOI{$vOOIddOOI} \def\vOOIdmOOI{$vOOIdmOOI} \
\def\vOOIfdOOI{$vOOIfdOOI} \def\vOOIfmOOI{$vOOIfmOOI}

\def\vOIIddOOI{$vOIIddOOI} \def\vOIIdmOOI{$vOIIdmOOI} \
\def\vOIIfdOOI{$vOIIfdOOI} \def\vOIIfmOOI{$vOIIfmOOI}
\def\vOIIddOII{$vOIIddOII} \def\vOIIdmOII{$vOIIdmOII} \
\def\vOIIfdOII{$vOIIfdOII} \def\vOIIfmOII{$vOIIfmOII}
\def\vOIIddIII{$vOIIddIII} \def\vOIIdmIII{$vOIIdmIII} \
\def\vOIIfdIII{$vOIIfdIII} \def\vOIIfmIII{$vOIIfmIII}

\def\vIIIddOOI{$vIIIddOOI} \def\vIIIdmOOI{$vIIIdmOOI} \
\def\vIIIfdOOI{$vIIIfdOOI} \def\vIIIfmOOI{$vIIIfmOOI}
\def\vIIIddOII{$vIIIddOII} \def\vIIIdmOII{$vIIIdmOII} \
\def\vIIIfdOII{$vIIIfdOII} \def\vIIIfmOII{$vIIIfmOII}
\def\vIIIddIII{$vIIIddIII} \def\vIIIdmIII{$vIIIdmIII} \
\def\vIIIfdIII{$vIIIfdIII} \def\vIIIfmIII{$vIIIfmIII}

\def\vOIVddOOI{$vOIVddOOI} \def\vOIVdmOOI{$vOIVdmOOI} \
\def\vOIVfdOOI{$vOIVfdOOI} \def\vOIVfmOOI{$vOIVfmOOI}

\def\vOOVddOOI{$vOOVddOOI} \def\vOOVdmOOI{$vOOVdmOOI} \
\def\vOOVfdOOI{$vOOVfdOOI} \def\vOOVfmOOI{$vOOVfmOOI}

\def\vOVIddOOI{$vOVIddOOI} \def\vOVIdmOOI{$vOVIdmOOI} \
\def\vOVIfdOOI{$vOVIfdOOI} \def\vOVIfmOOI{$vOVIfmOOI}
EOF
elif [ "$format" = "janvier" ]; then
    echo "$vOOIddOOI $vOOIdmOOI $vOOIfdOOI $vOOIfmOOI"
elif [ "$format" = "hiver" ]; then
    if [ "$zone" = A ]; then
        echo "$vOIIddOOI $vOIIdmOOI $vOIIfdOOI $vOIIfmOOI"
    elif [ "$zone" = B ]; then
        echo "$vOIIddOII $vOIIdmOII $vOIIfdOII $vOIIfmOII"
    else
        echo "$vOIIddIII $vOIIdmIII $vOIIfdIII $vOIIfmIII"
    fi
elif [ "$format" = "printemps" ]; then
    if [ "$zone" = A ]; then
        echo "$vIIIddOOI $vIIIdmOOI $vIIIfdOOI $vIIIfmOOI"
    elif [ "$zone" = B ]; then
        echo "$vIIIddOII $vIIIdmOII $vIIIfdOII $vIIIfmOII"
    else
        echo "$vIIIddIII $vIIIdmIII $vIIIfdIII $vIIIfmIII"
    fi
elif [ "$format" = "ete" ]; then
    echo "$vOIVddOOI $vOIVdmOOI $vOIVfdOOI $vOIVfmOOI"
elif [ "$format" = "toussaint" ]; then
    echo "$vOOVddOOI $vOOVdmOOI $vOOVfdOOI $vOOVfmOOI"
elif [ "$format" = "noel" ]; then
    echo "$vOVIddOOI $vOVIdmOOI $vOVIfdOOI $vOVIfmOOI"
fi
