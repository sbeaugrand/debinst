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

if [ "$year" = "2020" ]; then
    vOOIddOOI=01; vOOIdmOOI=01; vOOIfdOOI=05; vOOIfmOOI=01;

    vOIIddOOI=23; vOIIdmOOI=02; vOIIfdOOI=08; vOIIfmOOI=03;
    vOIIddOII=16; vOIIdmOII=02; vOIIfdOII=01; vOIIfmOII=03;
    vOIIddIII=09; vOIIdmIII=02; vOIIfdIII=23; vOIIfmIII=02;

    vIIIddOOI=19; vIIIdmOOI=04; vIIIfdOOI=03; vIIIfmOOI=05;
    vIIIddOII=12; vIIIdmOII=04; vIIIfdOII=26; vIIIfmOII=04;
    vIIIddIII=05; vIIIdmIII=04; vIIIfdIII=19; vIIIfmIII=04;

    vOIVddOOI=05; vOIVdmOOI=07; vOIVfdOOI=31; vOIVfmOOI=08;

    vOOVddOOI=18; vOOVdmOOI=10; vOOVfdOOI=01; vOOVfmOOI=11;

    vOVIddOOI=20; vOVIdmOOI=12; vOVIfdOOI=31; vOVIfmOOI=12;
elif [ "$year" = "2019" ]; then
    vOOIddOOI=01; vOOIdmOOI=01; vOOIfdOOI=06; vOOIfmOOI=01;

    vOIIddOOI=17; vOIIdmOOI=02; vOIIfdOOI=03; vOIIfmOOI=03;
    vOIIddOII=10; vOIIdmOII=02; vOIIfdOII=24; vOIIfmOII=02;
    vOIIddIII=24; vOIIdmIII=02; vOIIfdIII=10; vOIIfmIII=03;

    vIIIddOOI=14; vIIIdmOOI=04; vIIIfdOOI=28; vIIIfmOOI=04;
    vIIIddOII=07; vIIIdmOII=04; vIIIfdOII=21; vIIIfmOII=04;
    vIIIddIII=21; vIIIdmIII=04; vIIIfdIII=05; vIIIfmIII=05;

    vOIVddOOI=07; vOIVdmOOI=07; vOIVfdOOI=01; vOIVfmOOI=09;

    vOOVddOOI=20; vOOVdmOOI=10; vOOVfdOOI=03; vOOVfmOOI=11;

    vOVIddOOI=22; vOVIdmOOI=12; vOVIfdOOI=31; vOVIfmOOI=12;
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
