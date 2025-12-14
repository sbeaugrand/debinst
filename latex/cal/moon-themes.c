/******************************************************************************!
 * \file moon-themes.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include "algos.h"

enum sign {
    POISSON,
    VERSEAU,
    CAPRICORNE,
    SAGITTAIRE,
    SCORPION,
    BALANCE,
    VIERGE,
    LION,
    CANCER,
    GEMEAUX,
    TAUREAU,
    BELIER
};

/******************************************************************************!
 * \fn longitude
 ******************************************************************************/
static double
longitude(double jde)
{
    double t = julianTime(jde);
    double L = moonMeanLongitude(t);
    double D = moonMeanElongation1(t);
    double M = sunMeanAnomaly(t);
    double Mp = moonMeanAnomalyChapront(t);
    double F = moonArgumentOfLatitudeChapront(t);
    double E = moonMaximumDeclinationE(t);

    return moonApparentLongitude(t, L, D, M, Mp, F, E);
}

/******************************************************************************!
 * \fn theme
 ******************************************************************************/
static enum sign
theme(double l)
{
    //FIXME: approximatif et suffisant mais pourra quand meme etre ameliore'
    //FIXME: parallaxe ?
    if  /* */ (l >= 357.15) {
        return POISSON;
    } else if (l >= 326.00) {
        return VERSEAU;
    } else if (l >= 299.05) {
        return CAPRICORNE;
    } else if (l >= 266.40) {
        return SAGITTAIRE;
    } else if (l >= 242.00) {
        return SCORPION;
    } else if (l >= 217.15) {
        return BALANCE;
    } else if (l >= 172.00) {
        return VIERGE;
    } else if (l >= 137.00) {
        return LION;
    } else if (l >= 117.15) {
        return CANCER;
    } else if (l >= 90.25) {
        return GEMEAUX;
    } else if (l >= 53.20) {
        return TAUREAU;
    } else if (l >= 34.10) {
        return BELIER;
    } else {
        return POISSON;
    }
}

/******************************************************************************!
 * \fn printSign
 ******************************************************************************/
static void
printSign(enum sign s)
{
    switch (s) {
    case POISSON:
        printf("PO\n");
        break;
    case VERSEAU:
        printf("VE\n");
        break;
    case CAPRICORNE:
        printf("CA\n");
        break;
    case SAGITTAIRE:
        printf("SA\n");
        break;
    case SCORPION:
        printf("SC\n");
        break;
    case BALANCE:
        printf("BA\n");
        break;
    case VIERGE:
        printf("VI\n");
        break;
    case LION:
        printf("LI\n");
        break;
    case CANCER:
        printf("CN\n");
        break;
    case GEMEAUX:
        printf("GE\n");
        break;
    case TAUREAU:
        printf("TA\n");
        break;
    case BELIER:
        printf("BE\n");
        break;
    default:
        break;
    }

}

/******************************************************************************!
 * \fn themes
 ******************************************************************************/
static void
themes(int year, int month, int day)
{
    double j1 = julianDay(year, month, day);
    double l1 = longitude(j1);
    if (l1 < 0 || l1 > 360 + 34.10) {
        printf("%d\n", (int) l1);
        return;
    }

    enum sign t1 = theme(l1);
    printSign(t1);

    double j2 = j1 + 1;
    double l2 = longitude(j2);
    if (l2 < 0 || l2 > 360 + 34.10) {
        printf("%d\n", (int) l2);
        return;
    }
    enum sign t2 = theme(l2);
    if (t2 != t1) {
        double j0 = j1;
        double j = j1;
        while (j2 - j1 > 1.0 / 14400) {
            j = j1 + (j2 - j1) / 2;
            double l = longitude(j);
            if (l < 0 || l > 360 + 34.10) {
                printf("%d\n", (int) l);
                return;
            }
            if (t1 == theme(l)) {
                j1 = j;
            } else {
                j2 = j;
            }
        }
        double h = (j - j0) * 24 + gmtOffset(year, month, day);
        if (h >= 24) {
            return;
        }
        printSign(theme(longitude(j2)));
        printf(" %d:%02d\n", (int) h, (int) ((h - ((int) h)) * 60));
    }
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, const char* argv[])
{
    int year;
    int month;
    int day;

    if (argc != 2) {
        printf("Usage: %s <YYYY-MM-DD>\n", argv[0]);
        return EXIT_FAILURE;
    }
    sscanf(argv[1], "%d-%d-%d", &year, &month, &day);

    themes(year, month, day);

    return EXIT_SUCCESS;
}
