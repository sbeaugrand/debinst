# ---------------------------------------------------------------------------- #
## \file paques.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Source: https://www.tondering.dk/claus/cal/easter.php
## \brief Based in part on the algorithm of Oudin (1940)
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
## \fn paques
# ---------------------------------------------------------------------------- #
paques()
{
    ((Y = $1))
    ((G = Y % 19))
    ((C = Y / 100))
    ((H = (24 + 19 * G) % 30))
    ((I = H - H / 28))
    ((J = (Y + Y / 4 + I - 13) % 7))
    ((L = I - J))
    if [ "$2" = lundi ]; then
        ((L = L + 1))
    fi
    ((M = (3 + (L + 40) / 44)))
    ((D = L + 28 - M / 4 * 31))
}

# ---------------------------------------------------------------------------- #
## \fn ascension
# ---------------------------------------------------------------------------- #
ascension()
{
    ((AM = M + 1))
    ((AD = D + M + 4))
    ((NB = AM + 26))
    if ((AD > NB)); then
        ((AD = AD - NB))
        ((AM = AM + 1))
    fi
}

# ---------------------------------------------------------------------------- #
## \fn pentecote
# ---------------------------------------------------------------------------- #
pentecote()
{
    ((PM = AM))
    ((PD = AD + 11))
    ((NB = PM + 26))
    if ((PD > NB)); then
        ((PD = PD - NB))
        ((PM = PM + 1))
    fi
}