/******************************************************************************!
 * \file sun.c
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
 * \fn main
 ******************************************************************************/
int main(int argc, char* argv[])
{
    int year;
    int month;
    int day;
    double lat;
    double lon;
    double h0;

    if (argc != 4 && argc != 5 && argc != 6) {
        printf("Usage: %s <YYYY-MM-DD> <latitude> <longitude> [h0]\n",
               argv[0]);
        return EXIT_FAILURE;
    }
    sscanf(argv[1], "%d-%d-%d", &year, &month, &day);
    sscanf(argv[2], "%lf", &lat);
    sscanf(argv[3], "%lf", &lon);
    // Geometric altitude of the center of the body
    // at the time of apparent rising or setting
    // 34/60 = 0.5667
    // 0.833 in https://www.esrl.noaa.gov/gmd/grad/solcalc
    if (argc == 5) {
        sscanf(argv[4], "%lf", &h0);
    } else {
        h0 = -deg(0, 34, 0);
    }
    double gmtoff = gmtOffset(year, month, day);

    double jd = julianDay(year, month, day);
    double t = julianTime(jd);
    double eps;
    double dec;
    double ra;
    double nutationInLongitude;
    sunApparentRightAscensionAndDeclination(jd, &ra, &dec,
                                            &nutationInLongitude, &eps);
    double theta0 = reduceAngle(sideralTime(jd, t));
    theta0 = apparentSideralTime(theta0, nutationInLongitude, eps);

    double H0 =
        DEG(acos((SIN(h0) - SIN(lat) * SIN(dec)) / (COS(lat) * COS(dec))));
    double m0 = (ra - lon - theta0) / 360;
    if (m0 < 0) {
        m0 += 1;
    } else if (m0 >= 1) {
        m0 -= 1;
    }
    double m1 = m0 - H0 / 360;
    if (m1 < 0) {
        m1 += 1;
    } else if (m1 >= 1) {
        m1 -= 1;
    }
    double m2 = m0 + H0 / 360;
    if (m2 < 0) {
        m2 += 1;
    } else if (m2 >= 1) {
        m2 -= 1;
    }
#   ifdef WITH_INTERPOLATION
    double a1;
    double a2 = ra;
    double a3;
    double d1;
    double d2 = dec;
    double d3;
    sunApparentRightAscensionAndDeclination(jd - 1, &a1, &d1,
                                            &nutationInLongitude, &eps);
    sunApparentRightAscensionAndDeclination(jd + 1, &a3, &d3,
                                            &nutationInLongitude, &eps);
    double t1 = reduceAngle(theta0 + 360.985647 * m1);
    double t2 = reduceAngle(theta0 + 360.985647 * m0);
    double t3 = reduceAngle(theta0 + 360.985647 * m2);
    // deltaT
    // https://www.iers.org/IERS/EN/DataProducts/EarthOrientationData/eop.html
    double deltaT = 32.184 + 37;  // 2018
    double n0 = m0 + deltaT / 86400;
    double n1 = m1 + deltaT / 86400;
    double n2 = m2 + deltaT / 86400;
    double a;
    double b;
    double c;
    a = a2 - a1;
    b = a3 - a2;
    c = b - a;
    a1 = a2 + n1 * (a + b + n1 * c) / 2;
    a2 = a2 + n0 * (a + b + n0 * c) / 2;
    a3 = a2 + n2 * (a + b + n2 * c) / 2;
    a = d2 - d1;
    b = d3 - d2;
    c = b - a;
    d1 = d2 + n1 * (a + b + n1 * c) / 2;
    d3 = d2 + n2 * (a + b + n2 * c) / 2;
    double H1 = t1 + lon - a1;
    double H2 = t2 + lon - a2;
    double H3 = t3 + lon - a3;
    double h1 = DEG(asin(SIN(lat) * SIN(d1) + COS(lat) * COS(d1) * COS(H1)));
    double h3 = DEG(asin(SIN(lat) * SIN(d3) + COS(lat) * COS(d3) * COS(H3)));
    m0 += -H2 / 360;
    m1 += (h1 - h0) / (360 * COS(d1) * COS(lat) * SIN(H1));
    m2 += (h3 - h0) / (360 * COS(d3) * COS(lat) * SIN(H3));
#   endif
    double hr0 = m0 * 24 + gmtoff;
    double hr1 = m1 * 24 + gmtoff;
    double hr2 = m2 * 24 + gmtoff;
    int mi0 = round((hr0 - ((int) hr0)) * 60);
    int mi1 = round((hr1 - ((int) hr1)) * 60);
    int mi2 = round((hr2 - ((int) hr2)) * 60);
    if (mi0 == 60) {
        mi0 = 0;
        hr0 += 1;
    }
    if (mi1 == 60) {
        mi1 = 0;
        hr1 += 1;
    }
    if (mi2 == 60) {
        mi2 = 0;
        hr2 += 1;
    }
    /*  */ if (argc == 6 && *argv[5] == 'h') {
        printf("%02d", (int) hr0);
    } else if (argc == 6 && *argv[5] == 'm') {
        printf("%02d", mi0);
    } else {
        printf("%02d:%02d - %02d:%02d\n", (int) hr1, mi1, (int) hr2, mi2);
    }

    return EXIT_SUCCESS;
}
