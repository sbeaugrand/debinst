/******************************************************************************!
 * \file moon-events.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note Source: Astronomical algorithms - Jean Meeus - 1991
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "algos.h"

/******************************************************************************!
 * \fn apogeeOrPerigee
 ******************************************************************************/
int
apogeeOrPerigee(int year, int month, int day, int apogee, double k)
{
    double t;
    double jde;
    double D;
    double M;
    double F;
    int YY = year;
    int MM = month;
    int DD = day;
    int hh;
    int mm;

    t = moonApogeeOrPerigeeT(k);
    // Julian Ephemeris Day
    jde = moonJulianEphemerisDay(k, t);
    // Moon's mean elongation at time JDE
    D = moonMeanElongation(k, t);
    // Sun's meen anomaly
    M = moonSunMeanAnomaly(k, t);
    // Moon's argument of latitude
    F = moonArgumentOfLatitude(k, t);
    // Sum of the periodic terms
    if (apogee == 1) {
        jde += moonApogee(t, D, M, F);
    } else {
        jde += moonPerigee(t, D, M, F);
    }
    jde2date(jde, &YY, &MM, &DD, &hh, &mm);
    if (DD == day && MM == month && YY == year) {
        if (apogee == 1) {
            printf("AL");
        } else {
            printf("PL");
        }
        printf(" %02d:%02d\n", hh, mm);
        return 1;
    }
    return 0;
}

/******************************************************************************!
 * \fn ascendingOrDescendingNode
 ******************************************************************************/
int
ascendingOrDescendingNode(int year, int month, int day,
                          int ascending, double k)
{
    double t;
    double jde;
    double D;
    double M;
    double Mp;
    double omega;
    double V;
    double P;
    double E;
    int YY = year;
    int MM = month;
    int DD = day;
    int hh;
    int mm;

    t = moonNodeT(k);
    D = moonNodeD(k, t);
    M = moonNodeM(k, t);
    Mp = moonNodeMp(k, t);
    omega = moonNodeOmega(k, t);
    V = moonNodeV(t);
    P = moonNodeP(omega, t);
    E = moonMaximumDeclinationE(t);
    jde = moonNode(k, t, D, M, Mp, omega, V, P, E);
    jde2date(jde, &YY, &MM, &DD, &hh, &mm);
    if (DD == day && MM == month && YY == year) {
        if (ascending == 1) {
            printf("NA");
        } else {
            printf("ND");
        }
        printf(" %02d:%02d\n", hh, mm);
        return 1;
    }
    return 0;
}

/******************************************************************************!
 * \fn northOrSouthMaximumDeclination
 ******************************************************************************/
int
northOrSouthMaximumDeclination(int year, int month, int day,
                               int north, int k)
{
    double t;
    double jde;
    double D;
    double M;
    double Mp;
    double F;
    double E;
    int YY = year;
    int MM = month;
    int DD = day;
    int hh;
    int mm;

    t = moonMaximumDeclinationT(k);
    E = moonMaximumDeclinationE(t);
    if (north) {
        D = moonNorthernMaximumDeclinationD(k, t);
        M = moonNorthernMaximumDeclinationM(k, t);
        Mp = moonNorthernMaximumDeclinationMp(k, t);
        F = moonNorthernMaximumDeclinationF(k, t);
        jde = moonNorthernMaximumDeclination(k, t, D, M, Mp, F, E);
    } else {
        D = moonSouthernMaximumDeclinationD(k, t);
        M = moonSouthernMaximumDeclinationM(k, t);
        Mp = moonSouthernMaximumDeclinationMp(k, t);
        F = moonSouthernMaximumDeclinationF(k, t);
        jde = moonSouthernMaximumDeclination(k, t, D, M, Mp, F, E);
    }
    jde2date(jde, &YY, &MM, &DD, &hh, &mm);
    if (DD == day && MM == month && YY == year) {
        if (north == 1) {
            printf("LD");
        } else {
            printf("LM");
        }
        printf(" %02d:%02d\n", hh, mm);
        return 1;
    }
    return 0;
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char* argv[])
{
    double fYear;
    int year;
    int month;
    int day;
    int k;

    if (argc != 2) {
        printf("Usage: %s <YYYY-MM-DD>\n", argv[0]);
        return EXIT_FAILURE;
    }
    sscanf(argv[1], "%d-%d-%d", &year, &month, &day);
    fYear = yearWithDecimals(year, month, day);

    k = moonApogeeOrPerigeeK(fYear);
    if (apogeeOrPerigee(year, month, day, 1, k + 0.5) == 0 &&
        apogeeOrPerigee(year, month, day, 0, k) == 0) {
        apogeeOrPerigee(year, month, day, 0, k + 1);
    }
    k = moonNodeK(fYear);
    if (ascendingOrDescendingNode(year, month, day, 1, k) == 0) {
        ascendingOrDescendingNode(year, month, day, 0, k + 0.5);
    }
    k = moonMaximumDeclinationK(fYear);
    if (northOrSouthMaximumDeclination(year, month, day, 1, k) == 0) {
        northOrSouthMaximumDeclination(year, month, day, 0, k + 1);
    }

    return EXIT_SUCCESS;
}
