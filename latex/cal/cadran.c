/******************************************************************************!
 * \file cadran.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note Source: Astronomical algorithms - Jean Meeus - 1991
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "algos.h"

#define STYLUS_ANGLE 90  // 0: horizontal sundial, 90: vertical

#if ! defined(WITH_EQUATION_OF_TIME)
double gX;
double gY;
double gZ;

/******************************************************************************!
 * \fn roty
 ******************************************************************************/
void roty(double a)
{
    double lZ;

    a = RAD(a);
    lZ = gZ * cos(a) + gX * sin(a);
    gX = gX * cos(a) - gZ * sin(a);
    gZ = lZ;
}

/******************************************************************************!
 * \fn rotz
 ******************************************************************************/
void rotz(double a)
{
    double lX;

    a = RAD(a);
    lX = gX * cos(a) + gY * sin(a);
    gY = gY * cos(a) - gX * sin(a);
    gX = lX;
}
#endif

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int main(int argc, char* argv[])
{
    int year;
    int month;
    int day;
    double lat;
    double lon;
    double hour;
    double straightStylusLength;  // cm
    double gnomonicDeclination;  // west > 0, est < 0

    if (argc != 6 && argc != 7) {
        printf("Usage: %s <YYYY-MM-DD> <latitude> <longitude>"
               " <hour> <straight-stylus-length> [declination]\n",
               argv[0]);
        return EXIT_FAILURE;
    }
    sscanf(argv[1], "%d-%d-%d", &year, &month, &day);
    sscanf(argv[2], "%lf", &lat);
    sscanf(argv[3], "%lf", &lon);
    sscanf(argv[4], "%lf", &hour);
    sscanf(argv[5], "%lf", &straightStylusLength);
    if (argc == 7) {
        sscanf(argv[6], "%lf", &gnomonicDeclination);
    } else {
        gnomonicDeclination = 0;
    }

    // Julian Ephemeris Day
    double jd = julianDay(year, month, day + hour / 24.0);
    // Julian time
    double t = julianTime(jd);
    // Geometric mean longitude of the Sun
    double L = sunGeometricMeanLongitude(t);
    // Mean anomaly of the Sun
    double M = sunMeanAnomaly(t);
    // Sun's equation of center C
    double C = sunCenterEquation(t, M);
    // True geometric longitude referred to the mean equinox of the date
    double theta = sunTrueLongitude(L, C);
    // Apparent longitude referred to the true equinox of the date
    double lambda = sunApparentLongitude(t, theta);
    // Obliquity of the ecliptic
    double eps0 = eclipticObliquity(t);

#   if defined(WITH_ALTITUDE) || defined(WITH_EQUATION_OF_TIME)
    // Nutation in longitude and in obliquity
    double nutationInLongitude;
    double nutationInObliquity;
    nutation(t, &nutationInLongitude, &nutationInObliquity);
    // Corrected obliquity of the ecliptic
    double eps = eps0 + deg(0, 0, nutationInObliquity);
    // Apparent declination
    double dec = sunApparentDeclination(eps, lambda);
    // Apparent right ascension
    double ra = sunApparentRightAscension(eps, lambda);
#   endif
#   if defined(WITH_ALTITUDE)
    double h0 = deg(0, 34, 0);  // Geometric altitude of the
    // center of the body at the time of apparent rising or setting
    double alt =
        altitude(ra, dec,
                 apparentSideralTime(reduceAngle(sideralTime(jd, t)),
                                     nutationInLongitude, eps),
                 lat, -lon);
#   endif

#if defined(WITH_EQUATION_OF_TIME)
    double H = (hour - 12) * 15 - lon +
        equationOfTime(L, ra, nutationInLongitude, eps);
    double P =
        SIN(lat) * COS(STYLUS_ANGLE) -
        COS(lat) * SIN(STYLUS_ANGLE) * COS(gnomonicDeclination);
    double Q = SIN(gnomonicDeclination) * SIN(STYLUS_ANGLE) * SIN(H) +
        (COS(lat) * COS(STYLUS_ANGLE) +
         SIN(lat) * SIN(STYLUS_ANGLE) * COS(gnomonicDeclination)) * COS(H) +
        P * TAN(dec);
    if (
#       ifdef WITH_ALTITUDE
        alt > -h0 &&
#       endif
        Q > 0.1) {
        double nx =
            COS(gnomonicDeclination) * SIN(H) -
            SIN(gnomonicDeclination) *
            (SIN(lat) * COS(H) - COS(lat) * TAN(dec));
        double ny = COS(STYLUS_ANGLE) * SIN(gnomonicDeclination) * SIN(H) -
            (COS(lat) * SIN(STYLUS_ANGLE) - SIN(lat) *
             COS(STYLUS_ANGLE) * COS(gnomonicDeclination)) * COS(H) -
            (SIN(lat) * SIN(STYLUS_ANGLE) - COS(lat) *
             COS(STYLUS_ANGLE) * COS(gnomonicDeclination)) * TAN(dec);
        printf("%.7f %.7f\n",
               straightStylusLength * nx / Q,
               straightStylusLength * ny / Q);
    }
#else
#   if defined(WITH_ALTITUDE)
    gX = COS(ra) * COS(dec);
    gY = SIN(ra) * COS(dec);
    gZ = SIN(dec);
#   else
    // Corrected obliquity of the ecliptic
    double eps = eclipticObliquityCorrected(t, eps0);
    gX = COS(lambda);
    gY = COS(eps) * SIN(lambda);
    gZ = SIN(eps) * SIN(lambda);
#   endif

    rotz(L);
    rotz((hour - 24) * 15 - lon - 180);
    roty(90 - lat);
    rotz(-gnomonicDeclination);
    roty(STYLUS_ANGLE);
    double x = -straightStylusLength * gY / gZ;
    double y = straightStylusLength * gX / gZ;
    if (
#       ifdef WITH_ALTITUDE
        alt > -h0 &&
#       endif
        gZ > 0 &&
        x > -500 && x < 500 &&
        y > -500 && y < 500) {
        printf("%.7f %.7f\n", x, y);
    }
#endif

    return EXIT_SUCCESS;
}
