/******************************************************************************!
 * \file azimut.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note Source: Astronomical algorithms - Jean Meeus - 1991
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "algos.h"

int
main(int argc, char* argv[])
{
    int year;
    int month;
    int day;
    double lat;
    double lon;
    double hour;

    if (argc != 5) {
        printf("Usage: %s <YYYY-MM-DD> <latitude> <longitude> <hour>\n",
               argv[0]);
        return EXIT_FAILURE;
    }
    sscanf(argv[1], "%d-%d-%d", &year, &month, &day);
    sscanf(argv[2], "%lf", &lat);
    sscanf(argv[3], "%lf", &lon);
    sscanf(argv[4], "%lf", &hour);

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

    double theta0 = apparentSideralTime(reduceAngle(sideralTime(jd, t)),
                                        nutationInLongitude, eps);
    double h = altitude(ra, dec, theta0, lat, -lon);
    double a = azimut(ra, dec, theta0, lat, -lon);

    int hh = ra / 15;
    int mm = (ra - hh * 15) * 60 / 15;
    double ss = ((ra - hh * 15) * 60 / 15 - mm) * 60;
    printf("Ascension droite = %.7f (%dh %dm %.2fs)\n", ra, hh, mm, ss);
    hh = dec;
    mm = (dec - hh) * 60;
    ss = ((dec - hh) * 60 - mm) * 60;
    printf("Declinaison = %.7f (%dd %dm %.2fs)\n", dec, hh, mm, ss);
    printf("Azimut = %.7f\n", a + 180);
    printf("Hauteur = %.7f\n", h);

    return EXIT_SUCCESS;
}
