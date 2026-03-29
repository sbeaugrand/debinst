/******************************************************************************!
 * \file azimut.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note Heure pour mesurer la declinaison d'un mur :
 *         build/sun 2026-03-20 48.44728 1.48749 -4 s
 *         13:01:39
 *       Verifier une declinaison de 10 degres vers l'est :
 *         echo "12:01:39 12:30:00 14:30:00 16:30:00" | tr ' ' '\n' | xargs -I {} build/azimut 48.44728 1.48749 2026-03-20T{} | grep Azimut | awk '{ declination = -10; printf "%.1f\n", 180 - $3 + declination }'
 *         -10.0
 *         -19.5
 *         -55.3
 *         -82.5
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "algos.h"

int
main(int argc, const char* argv[])
{
    int year;
    int month;
    int day;
    int HH;
    int MM;
    int SS;
    double lat;
    double lon;
    double hour;

    if (argc != 4) {
        printf("Usage: %s <latitude> <longitude> <YYYY-mm-ddTHH:MM:SS>\n",
               argv[0]);
        return EXIT_FAILURE;
    }
    sscanf(argv[1], "%lf", &lat);
    sscanf(argv[2], "%lf", &lon);
    sscanf(argv[3], "%d-%d-%dT%d:%d:%d", &year, &month, &day, &HH, &MM, &SS);
    hour = HH + MM / 60.0 + SS / 3600.0;

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
