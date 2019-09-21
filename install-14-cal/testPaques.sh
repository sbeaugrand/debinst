#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file paques.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Source: https://www.tondering.dk/claus/cal/easter.php
## \brief Based in part on the algorithm of Oudin (1940)
# ---------------------------------------------------------------------------- #
source paques.sh

# ---------------------------------------------------------------------------- #
## \fn paquesOudin
# ---------------------------------------------------------------------------- #
paquesOudin()
{
    ((Y = $1))
    ((G = Y % 19))
    ((C = Y / 100))
    ((H = (C - C / 4 - (8 * C + 13) / 25 + 19 * G + 15 ) % 30))
    ((I = H - H / 28 * (1 - 29 / (H + 1) * (21 - G) / 11)))
    ((J = (Y + Y / 4 + I + 2 - C + C / 4) % 7))
    ((L = I - J))
    ((M = 3 + (L + 40) / 44))
    ((D = L + 28 - M / 4 * 31))
}

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
for ((Y = 1900; Y < 2100; Y++)); do
    paquesOudin $Y
    H1=$H
    I1=$I
    J1=$J
    paques $Y
    if ((H != H1)) || ((I != I1)) || ((J != J1)); then
        echo "error: Y=$Y G=$G H1=$H1 I1=$I1 J1=$J1 H2=$H I2=$I J2=$J"
        break
    fi
    printf "%02d-%02d-%d " $D $M $Y
    echo "G=$G H=$H1 I=$I1 J=$J1 L=$L"
done
