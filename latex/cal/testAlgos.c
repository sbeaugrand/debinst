/******************************************************************************!
 * \file tests.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note Source: Astronomical algorithms - Jean Meeus - 1991
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "algos.h"

#include <math.h>

int gErrors = 0;
const char* gTestRef;

/******************************************************************************!
 * \fn test
 ******************************************************************************/
void test(const char* testName, double cur, double ref)
{
    static char sCur[32];
    static char sRef[32];

    if (cur != ref) {
        sprintf(sCur, "%.7e", cur);
        sprintf(sRef, "%.7e", ref);
        if (strncmp(sCur, sRef, 32) != 0) {
            fprintf(stderr, "(%s) %s: %.7e (cur) != %.7e (ref)\n",
                    gTestRef, testName, cur, ref);
            ++gErrors;
        }
    }
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int main()
{
    double jd;
    double t;
    double L;
    double M;
    double e;
    double C;
    double theta;
    double lambda;
    double eps0;
    double eps;
    double ra;
    double dec;
    double nutationInLongitude;
    double nutationInObliquity;
    double theta0;

    // 7.a
    gTestRef = "7.a";
    test("Julian day", julianDay(1957, 10, 4.81), 2436116.31);

    // 24.a
    gTestRef = "24.a";
    test("Julian time",
         t = julianTime(julianDay(1992, 10, 13)), -0.072183436);
    test("Geometric mean longitude of the Sun",
         L = sunGeometricMeanLongitude(t), 201.807193);
    test("Mean anomaly of the Sun",
         M = sunMeanAnomaly(t), 278.99396);
    test("Eccentricity of the Earth's orbit",
         e = earthOrbitEccentricity(t), 0.016711651);
    test("Sun's equation of center C",
         C = sunCenterEquation(t, M), -1.897321);
    test("True geometric longitude referred to the mean equinox of the date",
         sunTrueLongitude(L, C), theta = 199.90987);
    test("Radius vector in astronomical units",
         sunRadius(e, sunTrueAnomaly(M, C)), 0.99766195);
    test("Apparent longitude referred to the true equinox of the date",
         lambda = sunApparentLongitude(t, theta), 199.90894);
    test("Obliquity of the ecliptic",
         eps0 = eclipticObliquity(t), 23.44023);
    test("Corrected obliquity of the ecliptic",
         eps = eclipticObliquityCorrected(t, eps0), 23.439991);
    test("Apparent right ascension",
         ra = sunApparentRightAscension(eps, lambda), 198.38082);
    test("Apparent declination",
         dec = sunApparentDeclination(eps, lambda), -7.7850688);
    // 24.b
    gTestRef = "24.b";
    nutation(t, &nutationInLongitude, &nutationInObliquity);
    test("Nutation in longitude",
         nutationInLongitude, 15.907675);
    test("Nutation in obliquity",
         nutationInObliquity, -0.30768173);
    test("True obliquity of the ecliptic",
         eps = eps0 + deg(0, 0, nutationInObliquity), 23.4401443);
    // 27.a
    gTestRef = "27.a";
    test("Equation of time",
         equationOfTime(201.807193, 198.378178, 0.004419 * 3600, eps),
         3.427351);

    // 21.a
    gTestRef = "21.a";
    t = -0.127296372348;
    test("Obliquity of the ecliptic",
         eps0 = eclipticObliquity(t), deg(23, 26, 27.407));
    nutation(t, &nutationInLongitude, &nutationInObliquity);
    test("Nutation in longitude",
         nutationInLongitude, -3.7879311);
    test("Nutation in obliquity",
         nutationInObliquity, 9.4425207);
    test("True obliquity of the ecliptic",
         eps = eps0 + deg(0, 0, nutationInObliquity), deg(23, 26, 36.850));
    // 11.a
    gTestRef = "11.a";
    test("Sideral time",
         theta0 = reduceAngle(sideralTime(2446895.5, t)),
         deg(13, 10, 46.3668) * 15);
    test("Apparent sideral time",
         apparentSideralTime(theta0, nutationInLongitude, eps),
         deg(13, 10, 46.1351) * 15);

    // 11.b
    gTestRef = "11.a";
    t = -0.12727430;
    test("Sideral time",
         theta0 = reduceAngle(sideralTime(2446896.30625, t)), 128.73787);
    // 12.b
    gTestRef = "11.b";
    nutation(t, &nutationInLongitude, &nutationInObliquity);
    test("Nutation in longitude",
         nutationInLongitude, -3.8672691);
    test("True obliquity of the ecliptic",
         eps = eclipticObliquity(t) + deg(0, 0, nutationInObliquity),
         deg(23, 26, 36.87));
    test("Apparent sideral time",
         theta0 = apparentSideralTime(theta0, nutationInLongitude, eps),
         deg(8, 34, 56.853) * 15);
    test("Altitude",
         altitude(deg(23, 9, 16.641) * 15, deg(-6, -43, -11.61),
                  theta0, deg(38, 55, 17), deg(5, 8, 15.7) * 15), 15.124874);

    // 14.a
    gTestRef = "14.a";
    jd = julianDay(1988, 3, 20);
    t = julianTime(jd);
    theta0 = reduceAngle(sideralTime(jd, t));
    nutation(t, &nutationInLongitude, &nutationInObliquity);
    eps = eclipticObliquity(t) + deg(0, 0, nutationInObliquity);
    test("Apparent sideral time",
         apparentSideralTime(theta0, nutationInLongitude, eps),
         177.74207);  // 177.74208
    theta0 = 177.74208;
    double lat = 42.3333;
    double lon = 71.0833;
    double a1 = 40.68021;
    double a2 = 41.73129;
    double a3 = 42.78204;
    double d1 = 18.04761;
    double d2 = 18.44092;
    double d3 = 18.82742;
    double h0 = -0.5667;
    double H0 =
        DEG(acos((SIN(h0) - SIN(lat) * SIN(d2)) / (COS(lat) * COS(d2))));
    test("H0", H0, 108.53437);  // 108.5344
    double m0 = (a2 + lon - theta0) / 360;
    if (m0 < 0) {
        m0 += 1;
    } else if (m0 >= 1) {
        m0 -= 1;
    }
    test("m0", m0, 0.81964586);  // 0.81965
    double m1 = m0 - H0 / 360;
    if (m1 < 0) {
        m1 += 1;
    } else if (m1 >= 1) {
        m1 -= 1;
    }
    test("m1", m1, 0.51816150);  // 0.51817
    double m2 = m0 + H0 / 360;
    if (m2 < 0) {
        m2 += 1;
    } else if (m2 >= 1) {
        m2 -= 1;
    }
    test("m2", m2, 0.12113022);  // 0.12113
    m1 = 0.51817;
    m0 = 0.81965;
    m2 = 0.12113;
    double t1 = reduceAngle(theta0 + 360.985647 * m1);
    double t2 = reduceAngle(theta0 + 360.985647 * m0);
    double t3 = reduceAngle(theta0 + 360.985647 * m2);
    test("t1", t1, 4.7940127);  // 4.79401
    test("t2", t2, 113.62397);
    test("t3", t3, 221.46827);
    // deltaT
    // https://www.iers.org/IERS/EN/DataProducts/EarthOrientationData/eop.html
    double deltaT = 56;  // 2018: 32.184 + 37
    double n0 = m0 + deltaT / 86400;
    double n1 = m1 + deltaT / 86400;
    double n2 = m2 + deltaT / 86400;
    test("n0", n0, 0.82029815);  // 0.82030
    test("n1", n1, 0.51881815);  // 0.51882
    test("n2", n2, 0.12177815);  // 0.12178
    double a;
    double b;
    double c;
    a = a2 - a1;
    b = a3 - a2;
    c = b - a;
    a1 = a2 + n1 * (a + b + n1 * c) / 2;
    test("a1", a1, 42.276479);  // 42.27648
    a3 = a2 + n2 * (a + b + n2 * c) / 2;
    test("a3", a3, 41.859266);  // 41.85927
    a2 = a2 + n0 * (a + b + n0 * c) / 2;
    test("a2", a2, 42.593243);  // 42.59324
    a1 = 42.27648;
    a3 = 41.85927;
    a = d2 - d1;
    b = d3 - d2;
    c = b - a;
    d1 = d2 + n1 * (a + b + n1 * c) / 2;
    test("d1", d1, 18.642293);  // 18.64229
    d3 = d2 + n2 * (a + b + n2 * c) / 2;
    test("d3", d3, 18.488351);  // 18.48835
    d1 = 18.64229;
    d3 = 18.48835;
    double H1 = t1 - lon - a1;
    double H2 = t2 - lon - a2;
    double H3 = t3 - lon - a3;
    test("H1", H1, -108.56577);
    test("H3", H3, 108.52570);
    H1 = -108.56577;
    H3 = 108.52570;
    double h1 = DEG(asin(SIN(lat) * SIN(d1) + COS(lat) * COS(d1) * COS(H1)));
    double h3 = DEG(asin(SIN(lat) * SIN(d3) + COS(lat) * COS(d3) * COS(H3)));
    test("h1", h1, -0.44392754);  // -0.44393
    test("h3", h3, -0.52710764);  // -0.52711
    h1 = -0.44393;
    h3 = -0.52711;
    double dm1 = (h1 - h0) / (360 * COS(d1) * COS(lat) * SIN(H1));
    double dm2 = -H2 / 360;
    double dm3 = (h3 - h0) / (360 * COS(d3) * COS(lat) * SIN(H3));
    test("dm1", dm1, -0.00051359492);  // -0.00051
    test("dm2", dm2, 0.00014604733);  // 0.00015
    test("dm3", dm3, 0.00016543225);  // 0.00017

    // 7.c
    gTestRef = "7.c";
    int YY = 1957;
    int MM = 10;
    int DD = 4;
    int hh;
    int mm;
    jde2date(2436116.31, &YY, &MM, &DD, &hh, &mm);
    test("YY", YY, 1957);
    test("MM", MM, 10);
    test("DD", DD, 4);
    test("hh", hh, (int) (0.81 * 24) + gmtOffset(YY, MM, DD));
    test("mm", mm, (int) ((0.81 * 24 + gmtOffset(YY, MM, DD) - hh) * 60));

    // 48.a
    gTestRef = "48.a";
    int year = 1988;
    int month = 10;
    int day = 1;
    double fYear = yearWithDecimals(year, month, day);
    test("year", fYear, 1988.75);
    double k = moonApogeeOrPerigeeK(fYear);
    test("k", k, -149);  // -148.5
    k = -148.5;
    t = moonApogeeOrPerigeeT(k);
    test("t", t, -0.11202897);  // -0.112029
    test("jde", moonJulianEphemerisDay(k, t), 2447442.8191);
    double D;
    double F;
    D = moonMeanElongation(k, t);
    M = moonSunMeanAnomaly(k, t);
    F = moonArgumentOfLatitude(k, t);
    test("D", D, 329.19299);  // 329.1930
    test("M", M, 274.41853);  // 274.4185
    test("F", F, 184.08526);  // 184.0853
    test("apogee (error not found)", moonApogee(t, D, M, F), -0.4654);

    // 48.perigee
    gTestRef = "48.perigee";
    year = 1997;
    month = 12;
    day = 9;
    fYear = yearWithDecimals(year, month, day);
    k = moonApogeeOrPerigeeK(fYear);
    t = moonApogeeOrPerigeeT(k);
    D = moonMeanElongation(k, t);
    M = moonSunMeanAnomaly(k, t);
    F = moonArgumentOfLatitude(k, t);
    jd = moonJulianEphemerisDay(k, t) + moonPerigee(t, D, M, F);
    jde2date(jd, &YY, &MM, &DD, &hh, &mm);
    YY = year;
    MM = month;
    DD = day;
    test("YY", YY, year);
    test("MM", MM, month);
    test("DD", DD, day);
    test("hh", hh, 16 + gmtOffset(YY, MM, DD));
    test("mm", mm, 9);

    // 49.a
    gTestRef = "49.a";
    year = 1987;
    month = 5;
    day = 15;
    fYear = yearWithDecimals(year, month, day);
    test("year", fYear, 1987.3717);  // 1987.37
    k = moonNodeK(fYear);
    test("k", k, -171);  // -170
    k = -170;
    t = moonNodeT(k);
    test("t", t, -0.1266549);  // -0.126655
    double Mp;
    double omega;
    double V;
    double P;
    double E;
    D = moonNodeD(k, t);
    test("D", D, 308.28735);
    M = moonNodeM(k, t);
    test("M", M, 137.93728);
    Mp = moonNodeMp(k, t);
    test("Mp", Mp, 78.707351);  // 78.70735
    omega = moonNodeOmega(k, t);
    test("omega", omega, 8.9449464);  // 8.9449
    V = moonNodeV(t);
    test("V", V, 282.92375);  // 282.92
    P = moonNodeP(omega, t);
    test("P", P, 281.98625);  // 281.99
    E = moonNodeE(t);
    test("E", E, 1.0003185);  // 1.000319
    jd = moonNode(k, t, D, M, Mp, omega, V, P, E);
    test("jde", jd, 2446938.76803);
    test("jde", jd - 2446938, 0.76802911);  // 0.76803
    YY = year;
    MM = month;
    DD = 23;
    jde2date(jd, &YY, &MM, &DD, &hh, &mm);
    test("YY", YY, year);
    test("MM", MM, month);
    test("DD", DD, 23);
    test("hh", hh, 6 + gmtOffset(YY, MM, DD));
    test("mm", mm, 25);  // 26 (25.96)

    // 50.a
    gTestRef = "50.a";
    year = 1988;
    month = 12;
    day = 14;
    fYear = yearWithDecimals(year, month, day);
    test("year", fYear, 1988.9523);  // 1988.95
    k = moonMaximumDeclinationK(fYear);
    test("k", k, -149);  // -148
    k = -148;
    t = moonMaximumDeclinationT(k);
    test("t", t, -0.11070718);  // 0.110707
    D = moonNorthernMaximumDeclinationD(k, t);
    test("D", D, 177.76086);  // 177.7608 !
    M = moonNorthernMaximumDeclinationM(k, t);
    test("M", M, 349.49154);  // 349.4915
    Mp = moonNorthernMaximumDeclinationMp(k, t);
    test("Mp", Mp, 95.158860);  // 95.1589
    F = moonNorthernMaximumDeclinationF(k, t);
    test("F", F, 111.76315);  // 111.7631 !
    E = moonMaximumDeclinationE(t);
    test("E", E, 1.0002784);  // 1.000278
    jd = moonNorthernMaximumDeclination(k, t, D, M, Mp, F, E);
    test("jde", jd, 2447518.3347);
    test("jde", jd - 2447518, 0.33465029);  // 0.3347
    YY = year;
    MM = month;
    DD = 22;
    jde2date(jd, &YY, &MM, &DD, &hh, &mm);
    test("YY", YY, year);
    test("MM", MM, month);
    test("DD", DD, 22);
    test("hh", hh, 20 + gmtOffset(YY, MM, DD));
    test("mm", mm, 1);  // 2

    // 50.b
    gTestRef = "50.b";
    year = 2049;
    month = 4;
    day = 21;
    k = 659;
    t = moonMaximumDeclinationT(k);
    D = moonSouthernMaximumDeclinationD(k, t);
    M = moonSouthernMaximumDeclinationM(k, t);
    Mp = moonSouthernMaximumDeclinationMp(k, t);
    F = moonSouthernMaximumDeclinationF(k, t);
    E = moonMaximumDeclinationE(t);
    jd = moonSouthernMaximumDeclination(k, t, D, M, Mp, F, E);
    test("jde", jd, 2469553.0834);
    test("jde", jd - 2469553, 0.083433989);  // 0.0834
    YY = year;
    MM = month;
    DD = day;
    jde2date(jd, &YY, &MM, &DD, &hh, &mm);
    test("YY", YY, year);
    test("MM", MM, month);
    test("DD", DD, day);
    test("hh", hh, 14 + gmtOffset(YY, MM, DD));
    test("mm", mm, 0);

    if (gErrors == 0) {
        return EXIT_SUCCESS;
    } else {
        return EXIT_FAILURE;
    }
}
