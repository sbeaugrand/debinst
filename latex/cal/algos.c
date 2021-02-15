/******************************************************************************!
 * \file algos.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note Source 1: Astronomical algorithms - Jean Meeus - 1991
 *       Source 2: Astronomical algorithms - Jean Meeus - 1998
 *       Source 3: Calculs astronomiques   - Jean Meeus - 2014
 ******************************************************************************/
#include <math.h>
#include <time.h>
#include "algos.h"

//#define JM1991
#define JM1998
//#define JM2014

/******************************************************************************!
 * \fn deg
 ******************************************************************************/
double
deg(double deg, double min, double sec)
{
    return deg + min / 60 + sec / 3600;
}

/******************************************************************************!
 * \fn reduceAngle
 * \brief Reduce angle to within 0..360 degrees
 ******************************************************************************/
double
reduceAngle(double a)
{
    return a - 360 * floor(a / 360);
}

/******************************************************************************!
 * \fn julianDay
 * \note 1: (7.1) p61
 *       2: (7.1) p61
 *       3: (3-1) p24
 ******************************************************************************/
double
julianDay(int Y, int M, double D)
{
    if (M < 3) {
        --Y;
        M += 12;
    }
    return
        ((int) (365.25 * (Y + 4716))) + ((int) (30.6001 * (M + 1))) + D +
        2 - ((int) (Y / 100)) + ((int) (((int) (Y / 100)) / 4)) - 1524.5;
}

/******************************************************************************!
 * \fn julianTime
 * \note 1: (24.1) p151
 *       2: (22.1) p143
 *       3: (7.1) p35 (13-1) p53
 ******************************************************************************/
double
julianTime(double jd)
{
    return (jd - 2451545) / 36525;
}

/******************************************************************************!
 * \fn sunGeometricMeanLongitude
 * \note 1: (24.2) p151 (27.2) p171
 *       2: (25.2) p163 (28.2) p183
 *       3: (13) p53
 ******************************************************************************/
double
sunGeometricMeanLongitude(double t)
{
    // 1:  reduceAngle(280.46645 + (36000.76983 + 0.0003032 * t) * t);
    // 2:  reduceAngle(280.46646 + (36000.76983 + 0.0003032 * t) * t);
    t /= 10;
#   ifdef JM1991
    return reduceAngle(280.4664567 +
                       (360007.6982779 +
                        (0.03032028 +
                         (1.0 / 49931 +
                          (-1.0 / 15299 - t / 1988000) * t) * t) * t) * t);
#   else
    return reduceAngle(280.4664567 +
                       (360007.6982779 +
                        (0.03032028 +
                         (1.0 / 49931 +
                          (-1.0 / 15300 - t / 2000000) * t) * t) * t) * t);
#   endif
}

/******************************************************************************!
 * \fn sunMeanAnomaly
 * \note 1: (21) p132 (24.3) p151
 *       2: (22) p144 (25.3) p163
 *       3: (13) p54
 ******************************************************************************/
double
sunMeanAnomaly(double t)
{
    //     reduceAngle(357.52772 +
    //                 (35999.05034 + (-0.0001603 - t / 300000) * t) * t);

#   ifdef JM1991
    return reduceAngle(357.52910 +
                       (35999.05030 + (-0.0001559 - 0.00000048 * t) * t) * t);
#   endif
#   ifdef JM1998
    return reduceAngle(357.52911 +
                       (35999.05029 + (-0.0001537) * t) * t);
#   endif
#   ifdef JM2014
    return reduceAngle(357.5291 +
                       (35999.0503 + (-0.000154) * t) * t);
#   endif
}

/******************************************************************************!
 * \fn earthOrbitEccentricity
 * \note 1: (24.4) p151
 *       2: (25.4) p163
 ******************************************************************************/
double
earthOrbitEccentricity(double t)
{
#   ifdef JM1991
    return 0.016708617 + (-0.000042037 - 0.0000001236 * t) * t;
#   else
    return 0.016708634 + (-0.000042037 - 0.0000001267 * t) * t;
#   endif
}

/******************************************************************************!
 * \fn sunCenterEquation
 * \note 1: (24) p152
 *       2: (25) p164
 ******************************************************************************/
double
sunCenterEquation(double t, double M)
{
#   ifdef JM1991
    return
        (1.914600 + (-0.004817 - 0.000014 * t) * t) * SIN(M) +
        (0.019993 - 0.000101 * t) * SIN(2 * M) + 0.000290 * SIN(3 * M);
#   else
    return
        (1.914602 + (-0.004817 - 0.000014 * t) * t) * SIN(M) +
        (0.019993 - 0.000101 * t) * SIN(2 * M) + 0.000289 * SIN(3 * M);
#   endif
}

/******************************************************************************!
 * \fn sunTrueLongitude
 ******************************************************************************/
double
sunTrueLongitude(double L, double C)
{
    return L + C;
}

/******************************************************************************!
 * \fn sunTrueAnomaly
 ******************************************************************************/
double
sunTrueAnomaly(double M, double C)
{
    return M + C;
}

/******************************************************************************!
 * \fn sunRadius
 * \note 1: (24.5) p152
 *       2: (25.5) p164
 ******************************************************************************/
double
sunRadius(double e, double nu)
{
    return 1.000001018 * (1 - e * e) / (1 + e * COS(nu));
}

/******************************************************************************!
 * \fn sunApparentLongitude
 * \note 1: (24) p153
 *       2: (25) p164
 ******************************************************************************/
double
sunApparentLongitude(double t, double theta)
{
    return theta - 0.00569 - 0.00478 * SIN(125.04 - 1934.136 * t);
}

/******************************************************************************!
 * \fn eclipticObliquity
 * \note 1: (21.2) p135
 *       2: (22.2) p147
 ******************************************************************************/
double
eclipticObliquity(double t)
{
    return
        deg(23, 26, 21.448) +
        (-deg(0, 0, 46.8150) +
         (-deg(0, 0, 0.00059) + deg(0, 0.001813, 0) * t) * t) * t;
}

/******************************************************************************!
 * \fn eclipticObliquityCorrected
 * \note 1: (24.8) p153
 *       2: (25.8) p164
 ******************************************************************************/
double
eclipticObliquityCorrected(double t, double eps)
{
    return eps + 0.00256 * COS(125.04 - 1934.136 * t);
}

/******************************************************************************!
 * \fn sunApparentRightAscension
 * \note 1: (24.6) p153
 *       2: (25.6) p165
 ******************************************************************************/
double
sunApparentRightAscension(double eps, double theta)
{
    double a = atan2(COS(eps) * SIN(theta), COS(theta));
    if (a < 0) {
        return DEG(a) + 360;
    } else {
        return DEG(a);
    }
}

/******************************************************************************!
 * \fn sunApparentDeclination
 * \note 1: (24.7) p153
 *       2: (25.7) p165
 ******************************************************************************/
double
sunApparentDeclination(double eps, double theta)
{
    return DEG(asin(SIN(eps) * SIN(theta)));
}

/******************************************************************************!
 * \fn sideralTime
 * \note 1: (11.4) p84
 *       2: (12.4) p88
 ******************************************************************************/
double
sideralTime(double jd, double t)
{
    return
        280.46061837 + 360.98564736629 *
        (jd - 2451545) + (0.000387933 - t / 38710000) * t * t;
}

/******************************************************************************!
 * \fn nutation
 * \note 1: (21) p132
 *       2: (22) p144
 *       3: (13) p54
 ******************************************************************************/
void
nutation(double t, double* nutationInLongitude, double* nutationInObliquity)
{
    // Mean elongation of the Moon from the Sun
    double D = 297.85036 + (445267.111480 + (-0.0019142 + t / 189474) * t) * t;
    // Mean anomaly of the Sun (Earth)
    double M = 357.52772 + (35999.050340 + (-0.0001603 - t / 300000) * t) * t;
    // Mean anomaly of the Moon
#   ifdef JM2014
    double Mp = 134.9634 + (477198.8675 + (0.008721 + t / 56250) * t) * t;
#   else
    double Mp = 134.96298 + (477198.867398 + (0.0086972 + t / 56250) * t) * t;
#   endif
    // Moon's argument of latitude
    double F = 93.27191 + (483202.017538 + (-0.0036825 + t / 327270) * t) * t;
    // Longitude of the ascending node of the Moon's mean orbit on the
    // ecliptic, measured form the mean equinox of the date
#   ifdef JM2014
    double
        omega = 125.0443 + (-1934.1363 + (0.002075 + t / 450000) * t) * t;
#   else
    double
        omega = 125.04452 + (-1934.136261 + (0.0020708 + t / 450000) * t) * t;
#   endif

    *nutationInLongitude = 0;
    *nutationInObliquity = 0;
    double a = omega;
    *nutationInLongitude += (-171996 - 174.2 * t) * SIN(a);
    *nutationInObliquity += (92025 + 8.9 * t) * COS(a);
    a = -2 * D + 2 * F + 2 * omega;
    *nutationInLongitude += (-13187 - 1.6 * t) * SIN(a);
    *nutationInObliquity += (5736 - 3.1 * t) * COS(a);
    a = 2 * F + 2 * omega;
    *nutationInLongitude += (-2274 - 0.2 * t) * SIN(a);
    *nutationInObliquity += (977 - 0.5 * t) * COS(a);
    a = 2 * omega;
    *nutationInLongitude += (2062 + 0.2 * t) * SIN(a);
    *nutationInObliquity += (-895 + 0.5 * t) * COS(a);
    a = M;
    *nutationInLongitude += (1426 - 3.4 * t) * SIN(a);
    *nutationInObliquity += (54 - 0.1 * t) * COS(a);
    a = Mp;
    *nutationInLongitude += (712 + 0.1 * t) * SIN(a);
    *nutationInObliquity += -7 * COS(a);
    a = -2 * D + M + 2 * F + 2 * omega;
    *nutationInLongitude += (-517 + 1.2 * t) * SIN(a);
    *nutationInObliquity += (224 - 0.6 * t) * COS(a);
    a = 2 * F + omega;
    *nutationInLongitude += (-386 - 0.4 * t) * SIN(a);
    *nutationInObliquity += 200 * COS(a);
    a = Mp + 2 * F + 2 * omega;
    *nutationInLongitude += -301 * SIN(a);
    *nutationInObliquity += (129 - 0.1 * t) * COS(a);
    a = -2 * D - M + 2 * F + 2 * omega;
    *nutationInLongitude += (217 - 0.5 * t) * SIN(a);
    *nutationInObliquity += (-95 + 0.3 * t) * COS(a);
    a = -2 * D + Mp;
    *nutationInLongitude += -158 * SIN(a);
    a = -2 * D + 2 * F + omega;
    *nutationInLongitude += (129 + 0.1 * t) * SIN(a);
    *nutationInObliquity += -70 * COS(a);
    a = -Mp + 2 * F + 2 * omega;
    *nutationInLongitude += 123 * SIN(a);
    *nutationInObliquity += -53 * COS(a);
    a = 2 * D;
    *nutationInLongitude += 63 * SIN(a);
    a = Mp + omega;
    *nutationInLongitude += (63 + 0.1 * t) * SIN(a);
    *nutationInObliquity += -33 * COS(a);
    a = 2 * D - Mp + 2 * F + 2 * omega;
    *nutationInLongitude += -59 * SIN(a);
    *nutationInObliquity += 26 * COS(a);
    a = -Mp + omega;
    *nutationInLongitude += (-58 - 0.1 * t) * SIN(a);
    *nutationInObliquity += 32 * COS(a);
    a = Mp + 2 * F + omega;
    *nutationInLongitude += -51 * SIN(a);
    *nutationInObliquity += 27 * COS(a);
    a = -2 * D + 2 * Mp;
    *nutationInLongitude += 48 * SIN(a);
    a = -2 * Mp + 2 * F + omega;
    *nutationInLongitude += 46 * SIN(a);
    *nutationInObliquity += -24 * COS(a);
    a = 2 * D + 2 * F + 2 * omega;
    *nutationInLongitude += -38 * SIN(a);
    *nutationInObliquity += 16 * COS(a);
    a = 2 * Mp + 2 * F + 2 * omega;
    *nutationInLongitude += -31 * SIN(a);
    *nutationInObliquity += 13 * COS(a);
    a = 2 * Mp;
    *nutationInLongitude += 29 * SIN(a);
    a = -2 * D + Mp + 2 * F + 2 * omega;
    *nutationInLongitude += 29 * SIN(a);
    *nutationInObliquity += -12 * COS(a);
    a = 2 * F;
    *nutationInLongitude += 26 * SIN(a);
    a = -2 * D + 2 * F;
    *nutationInLongitude += -22 * SIN(a);
    a = -Mp + 2 * F + omega;
    *nutationInLongitude += 21 * SIN(a);
    *nutationInObliquity += -10 * COS(a);
    a = 2 * M;
    *nutationInLongitude += (17 - 0.1 * t) * SIN(a);
    a = 2 * D - Mp + omega;
    *nutationInLongitude += 16 * SIN(a);
    *nutationInObliquity += -8 * COS(a);
    a = -2 * D + 2 * M + 2 * F + 2 * omega;
    *nutationInLongitude += (-16 + 0.1 * t) * SIN(a);
    *nutationInObliquity += 7 * COS(a);
    a = M + omega;
    *nutationInLongitude += -15 * SIN(a);
    *nutationInObliquity += 9 * COS(a);
    a = -2 * D + Mp + omega;
    *nutationInLongitude += -13 * SIN(a);
    *nutationInObliquity += 7 * COS(a);
    a = -M + omega;
    *nutationInLongitude += -12 * SIN(a);
    *nutationInObliquity += 6 * COS(a);
    a = 2 * Mp - 2 * F;
    *nutationInLongitude += 11 * SIN(a);
    a = 2 * D - Mp + 2 * F + omega;
    *nutationInLongitude += -10 * SIN(a);
    *nutationInObliquity += 5 * COS(a);
    a = 2 * D + Mp + 2 * F + 2 * omega;
    *nutationInLongitude += -8 * SIN(a);
    *nutationInObliquity += 3 * COS(a);
    a = M + 2 * F + 2 * omega;
    *nutationInLongitude += 7 * SIN(a);
    *nutationInObliquity += -3 * COS(a);
    a = -2 * D + M + Mp;
    *nutationInLongitude += -7 * SIN(a);
    a = -M + 2 * F + 2 * omega;
    *nutationInLongitude += -7 * SIN(a);
    *nutationInObliquity += 3 * COS(a);
    a = 2 * D + 2 * F + omega;
    *nutationInLongitude += -7 * SIN(a);
    *nutationInObliquity += 3 * COS(a);
    a = 2 * D + Mp;
    *nutationInLongitude += 6 * SIN(a);
    a = -2 * D + 2 * Mp + 2 * F + 2 * omega;
    *nutationInLongitude += 6 * SIN(a);
    *nutationInObliquity += -3 * COS(a);
    a = -2 * D + Mp + 2 * F + omega;
    *nutationInLongitude += 6 * SIN(a);
    *nutationInObliquity += -3 * COS(a);
    a = 2 * D - 2 * Mp + omega;
    *nutationInLongitude += -6 * SIN(a);
    *nutationInObliquity += 3 * COS(a);
    a = 2 * D + omega;
    *nutationInLongitude += -6 * SIN(a);
    *nutationInObliquity += 3 * COS(a);
    a = -M + Mp;
    *nutationInLongitude += 5 * SIN(a);
    a = -2 * D - M + 2 * F + omega;
    *nutationInLongitude += -5 * SIN(a);
    *nutationInObliquity += 3 * COS(a);
    a = -2 * D + omega;
    *nutationInLongitude += -5 * SIN(a);
    *nutationInObliquity += 3 * COS(a);
    a = 2 * Mp + 2 * F + omega;
    *nutationInLongitude += -5 * SIN(a);
    *nutationInObliquity += 3 * COS(a);
    a = -2 * D + 2 * Mp + omega;
    *nutationInLongitude += 4 * SIN(a);
    a = -2 * D + M + 2 * F + omega;
    *nutationInLongitude += 4 * SIN(a);
    a = Mp - 2 * F;
    *nutationInLongitude += 4 * SIN(a);
    a = -D + Mp;
    *nutationInLongitude += -4 * SIN(a);
    a = -2 * D + M;
    *nutationInLongitude += -4 * SIN(a);
    a = D;
    *nutationInLongitude += -4 * SIN(a);
    a = Mp + 2 * F;
    *nutationInLongitude += 3 * SIN(a);
    a = -2 * Mp + 2 * F + 2 * omega;
    *nutationInLongitude += -3 * SIN(a);
    a = -D - M + Mp;
    *nutationInLongitude += -3 * SIN(a);
    a = M + Mp;
    *nutationInLongitude += -3 * SIN(a);
    a = -M + Mp + 2 * F + 2 * omega;
    *nutationInLongitude += -3 * SIN(a);
    a = 2 * D - M - Mp + 2 * F + 2 * omega;
    *nutationInLongitude += -3 * SIN(a);
    a = 3 * Mp + 2 * F + 2 * omega;
    *nutationInLongitude += -3 * SIN(a);
    a = 2 * D - M + 2 * F + 2 * omega;
    *nutationInLongitude += -3 * SIN(a);

    *nutationInLongitude *= 0.0001;
    *nutationInObliquity *= 0.0001;
}

/******************************************************************************!
 * \fn apparentSideralTime
 ******************************************************************************/
double
apparentSideralTime(double theta0, double nutationInLongitude, double eps)
{
    return theta0 + deg(0, 0, nutationInLongitude * COS(eps));
}

/******************************************************************************!
 * \fn altitude
 * \note 1: (12.6) p89
 *       2: (13.6) p93
 ******************************************************************************/
double
altitude(double ra, double dec, double theta0, double lat, double lon)
{
    double H = reduceAngle(theta0 - lon - ra);  // Local hour angle
    return DEG(asin(SIN(lat) * SIN(dec) + COS(lat) * COS(dec) * COS(H)));
}

/******************************************************************************!
 * \fn equationOfTime
 * \note 1: (27.1) p171
 *       2: (28.1) p171
 ******************************************************************************/
double
equationOfTime(double L, double ra, double nutationInLongitude, double eps)
{
    return L - 0.0057183 - ra + deg(0, 0, nutationInLongitude) * COS(eps);
}

/******************************************************************************!
 * \fn gmtOffset
 ******************************************************************************/
double
gmtOffset(int year, int month, int day)
{
    struct tm tmp = {
        0
    };
    tmp.tm_year = year - 1900;
    tmp.tm_mon = month - 1;
    tmp.tm_mday = day;
    tmp.tm_hour = 12;
    mktime(&tmp);
    return ((double) tmp.tm_gmtoff) / 3600;
}

/******************************************************************************!
 * \fn sunApparentRightAscensionAndDeclination
 ******************************************************************************/
void
sunApparentRightAscensionAndDeclination(double jd, double* ra, double* dec,
                                        double* nutationInLongitude,
                                        double* eps)
{
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
    double nutationInObliquity;
    nutation(t, nutationInLongitude, &nutationInObliquity);
    // Corrected obliquity of the ecliptic
    *eps = eps0 + deg(0, 0, nutationInObliquity);
    // Apparent declination
    *dec = sunApparentDeclination(*eps, lambda);
    // Apparent right ascension
    *ra = sunApparentRightAscension(*eps, lambda);
}

/******************************************************************************!
 * \fn jde2date
 ******************************************************************************/
void
jde2date(double jde, int* YY, int* MM, int* DD, int* hh, int* mm)
{
    double tt;
    int z;
    int alpha;
    int a;
    int b;
    int c;
    int d;
    int e;

    jde += 0.5;
    jde += gmtOffset(*YY, *MM, *DD) / 24;
    z = jde;
    alpha = (z - 1867216.25) / 36524.25;
    a = z + 1 + alpha - ((int) (alpha / 4));
    b = a + 1524;
    c = (b - 122.1) / 365.25;
    d = 365.25 * c;
    e = (b - d) / 30.6001;
    *DD = b - d - ((int) (30.6001 * e));
    *MM = e - ((e < 14) ? 1 : 13);
    *YY = c - ((*MM > 2) ? 4716 : 4715);
    tt = (jde - z) * 24;
    *hh = tt;
    *mm = (tt - *hh) * 60;
}

/******************************************************************************!
 * \fn moonJulianEphemerisDay
 * \note 1: (48.1) p 325
 *       2: (50.1) p 355
 ******************************************************************************/
double
moonJulianEphemerisDay(double k, double t)
{
#   ifdef JM1991
    return
        2451534.6698 + 27.55454988 * k +
        (-0.0006886 + (-0.000001098 + 0.0000000052 * t) * t) * t * t;
#   else
    return
        2451534.6698 + 27.55454989 * k +
        (-0.0006691 + (-0.000001098 + 0.0000000052 * t) * t) * t * t;
#   endif
}

/******************************************************************************!
 * \fn moonMeanElongation
 * \note 1: (48) p 326
 *       2: (50) p 356
 ******************************************************************************/
double
moonMeanElongation(double k, double t)
{
#   ifdef JM1991
    return
        reduceAngle(171.9179 + 335.9106046 * k +
                    (-0.0100250 + (-0.00001156 + 0.000000055 * t) * t) * t * t);
#   else
    return
        reduceAngle(171.9179 + 335.9106046 * k +
                    (-0.0100383 + (-0.00001156 + 0.000000055 * t) * t) * t * t);
#   endif
}

/******************************************************************************!
 * \fn moonSunMeanAnomaly
 * \note 1: (48) p 326
 *       2: (50) p 356
 ******************************************************************************/
double
moonSunMeanAnomaly(double k, double t)
{
#   ifdef JM1991
    return
        reduceAngle(347.3477 + 27.1577721 * k +
                    (-0.0008323 - 0.0000010 * t) * t * t);
#   else
    return
        reduceAngle(347.3477 + 27.1577721 * k +
                    (-0.0008130 - 0.0000010 * t) * t * t);
#   endif
}

/******************************************************************************!
 * \fn moonArgumentOfLatitude
 * \note 1: (48) p 326
 *       2: (50) p 356
 ******************************************************************************/
double
moonArgumentOfLatitude(double k, double t)
{
#   ifdef JM1991
    return
        reduceAngle(316.6109 + 364.5287911 * k +
                    (-0.0125131 - 0.0000148 * t) * t * t);
#   else
    return
        reduceAngle(316.6109 + 364.5287911 * k +
                    (-0.0125053 - 0.0000148 * t) * t * t);
#   endif
}

/******************************************************************************!
 * \fn moonApogee
 ******************************************************************************/
double
moonApogee(double t, double D, double M, double F)
{
    D *= M_PI / 180;
    M *= M_PI / 180;
    F *= M_PI / 180;
    return
        0.4392 * sin(2 * D) +
        0.0684 * sin(4 * D) +
        (0.0456 - 0.00011 * t) * sin(M) +
        (0.0426 - 0.00011 * t) * sin(2 * D - M) +
        0.0212 * sin(2 * F) +
        -0.0189 * sin(D) +
        0.0144 * sin(6 * D) +
        0.0113 * sin(4 * D - M) +
        0.0047 * sin(2 * D + 2 * F) +
        0.0036 * sin(D + M) +
        0.0035 * sin(8 * D) +
        0.0034 * sin(6 * D - M) +
        -0.0034 * sin(2 * D - 2 * F) +
        0.0022 * sin(2 * D - 2 * M) +
        -0.0017 * sin(3 * D) +
        0.0013 * sin(4 * D + 2 * F) +
        0.0011 * sin(8 * D - M) +
        0.0010 * sin(4 * D - 2 * M) +
        0.0009 * sin(10 * D) +
        0.0007 * sin(3 * D + M) +
        0.0006 * sin(2 * M) +
        0.0005 * sin(2 * D + M) +
        0.0005 * sin(2 * D + 2 * M) +
        0.0004 * sin(6 * D + 2 * F) +
        0.0004 * sin(6 * D - 2 * M) +
        0.0004 * sin(10 * D - M) +
        -0.0004 * sin(5 * D) +
        -0.0004 * sin(4 * D - 2 * F) +
        0.0003 * sin(2 * F + M) +
        0.0003 * sin(12 * D) +
        0.0003 * sin(2 * D + 2 * F - M) +
        -0.0003 * sin(D - M);
}

/******************************************************************************!
 * \fn moonPerigee
 ******************************************************************************/
double
moonPerigee(double t, double D, double M, double F)
{
    D *= M_PI / 180;
    M *= M_PI / 180;
    F *= M_PI / 180;
    return
        -1.6769 * sin(2 * D) +
        0.4589 * sin(4 * D) +
        -0.1856 * sin(6 * D) +
        0.0883 * sin(8 * D) +
        (-0.0773 + 0.00019 * t) * sin(2 * D - M) +
        (0.0502 - 0.00013 * t) * sin(M) +
        -0.0460 * sin(10 * D) +
        (0.0422 - 0.00011 * t) * sin(4 * D - M) +
        -0.0256 * sin(6 * D - M) +
        0.0253 * sin(12 * D) +
        0.0237 * sin(D) +
        0.0162 * sin(8 * D - M) +
        -0.0145 * sin(14 * D) +
        0.0129 * sin(2 * F) +
        -0.0112 * sin(3 * D) +
        -0.0104 * sin(10 * D - M) +
        0.0086 * sin(16 * D) +
        0.0069 * sin(12 * D - M) +
        0.0066 * sin(5 * D) +
        -0.0053 * sin(2 * D + 2 * F) +
        -0.0052 * sin(18 * D) +
        -0.0046 * sin(14 * D - M) +
        -0.0041 * sin(7 * D) +
        0.0040 * sin(2 * D + M) +
        0.0032 * sin(20 * D) +
        -0.0032 * sin(D + M) +
        0.0031 * sin(16 * D - M) +
        -0.0029 * sin(4 * D + M) +
        0.0027 * sin(9 * D) +
        0.0027 * sin(4 * D + 2 * F) +
        -0.0027 * sin(2 * D - 2 * M) +
        0.0024 * sin(4 * D - 2 * M) +
        -0.0021 * sin(6 * D - 2 * M) +
        -0.0021 * sin(22 * D) +
        -0.0021 * sin(18 * D - M) +
        0.0019 * sin(6 * D + M) +
        -0.0018 * sin(11 * D) +
        -0.0014 * sin(8 * D + M) +
        -0.0014 * sin(4 * D - 2 * F) +
        -0.0014 * sin(6 * D + 2 * F) +
        0.0014 * sin(3 * D + M) +
        -0.0014 * sin(5 * D + M) +
        0.0013 * sin(13 * D) +
        0.0013 * sin(20 * D - M) +
        0.0011 * sin(3 * D + 2 * M) +
        -0.0011 * sin(4 * D + 2 * F - 2 * M) +
        -0.0010 * sin(D + 2 * M) +
        -0.0009 * sin(22 * D - M) +
        -0.0008 * sin(4 * F) +
        0.0008 * sin(6 * D - 2 * F) +
        0.0008 * sin(2 * D - 2 * F + M) +
        0.0007 * sin(2 * M) +
        0.0007 * sin(2 * F - M) +
        0.0007 * sin(2 * D + 4 * F) +
        -0.0006 * sin(2 * F - 2 * M) +
        -0.0006 * sin(2 * D - 2 * F + 2 * M) +
        0.0006 * sin(24 * D) +
        0.0005 * sin(4 * D - 4 * F) +
        0.0005 * sin(2 * D + 2 * M) +
        -0.0004 * sin(D - M);
}

/******************************************************************************!
 * \fn moonNodeD
 * \note 1: (49) p333
 *       2: (51) p363
 ******************************************************************************/
double
moonNodeD(double k, double t)
{
#   ifdef JM1991
    return
        reduceAngle(183.6380 + 331.73735691 * k +
                    (0.0015057 + (0.00000209 - 0.000000010 * t) * t) * t * t);
#   else
    return
        reduceAngle(183.6380 + 331.73735682 * k +
                    (0.0014852 + (0.00000209 - 0.000000010 * t) * t) * t * t);
#   endif
}

/******************************************************************************!
 * \fn moonNodeM
 * \note 1: (49) p333
 *       2: (51) p363
 ******************************************************************************/
double
moonNodeM(double k, double t)
{
#   ifdef JM1991
    return
        reduceAngle(17.4006 + 26.82037250 * k +
                    (0.0000999 + 0.00000006 * t) * t * t);
#   else
    return
        reduceAngle(17.4006 + 26.82037250 * k +
                    (0.0001186 + 0.00000006 * t) * t * t);
#   endif
}

/******************************************************************************!
 * \fn moonNodeMp
 * \note 1: (49) p334
 *       2: (51) p363
 ******************************************************************************/
double
moonNodeMp(double k, double t)
{
#   ifdef JM1991
    return
        reduceAngle(38.3776 + 355.52747322 * k +
                    (0.0123577 + (0.000014628 - 0.000000069 * t) * t) * t * t);
#   else
    return
        reduceAngle(38.3776 + 355.52747313 * k +
                    (0.0123499 + (0.000014627 - 0.000000069 * t) * t) * t * t);
#   endif
}

/******************************************************************************!
 * \fn moonNodeOmega
 * \note 1: (49) p334
 *       2: (51) p364
 ******************************************************************************/
double
moonNodeOmega(double k, double t)
{
#   ifdef JM1991
    return
        reduceAngle(123.9767 - 1.44098949 * k +
                    (0.0020625 + (0.00000214 - 0.000000016 * t) * t) * t * t);
#   else
    return
        reduceAngle(123.9767 - 1.44098956 * k +
                    (0.0020608 + (0.00000214 - 0.000000016 * t) * t) * t * t);
#   endif
}

/******************************************************************************!
 * \fn moonNodeV
 ******************************************************************************/
double
moonNodeV(double t)
{
    return reduceAngle(299.75 + (132.85 - 0.009173 * t) * t);
}

/******************************************************************************!
 * \fn moonNodeP
 ******************************************************************************/
double
moonNodeP(double omega, double t)
{
    return reduceAngle(omega + 272.75 - 2.3 * t);
}

/******************************************************************************!
 * \fn moonNodeE
 ******************************************************************************/
double
moonNodeE(double t)
{
    return 1 + (-0.002516 - 0.0000074 * t) * t;
}

/******************************************************************************!
 * \fn moonNode
 ******************************************************************************/
double
moonNode(double k, double t, double D,
         double M, double Mp, double omega, double V, double P, double E)
{
    D *= M_PI / 180;
    M *= M_PI / 180;
    Mp *= M_PI / 180;
    omega *= M_PI / 180;
    V *= M_PI / 180;
    P *= M_PI / 180;
    return
        2451565.1619 + 27.212220817 * k +
        (0.0002572 + (0.000000021 - 0.000000000088 * t) * t) * t * t +
        -0.4721 * sin(Mp) +
        -0.1649 * sin(2 * D) +
        -0.0868 * sin(2 * D - Mp) +
        0.0084 * sin(2 * D + Mp) +
        -0.0083 * sin(2 * D - M) * E +
        -0.0039 * sin(2 * D - M - Mp) * E +
        0.0034 * sin(2 * Mp) +
        -0.0031 * sin(2 * D - 2 * Mp) +
        0.0030 * sin(2 * D + M) * E +
        0.0028 * sin(M - Mp) * E +
        0.0026 * sin(M) * E +
        0.0025 * sin(4 * D) +
        0.0024 * sin(D) +
        0.0022 * sin(M + Mp) * E +
        0.0017 * sin(omega) +
        0.0014 * sin(4 * D - Mp) +
        0.0005 * sin(2 * D + M - Mp) * E +
        0.0004 * sin(2 * D - M + Mp) * E +
        -0.0003 * sin(2 * D - 2 * M) * E +
        0.0003 * sin(4 * D - M) * E +
        0.0003 * sin(V) +
        0.0003 * sin(P);
}

/******************************************************************************!
 * \fn moonMaximumDeclinationE
 ******************************************************************************/
double
moonMaximumDeclinationE(double t)
{
    return 1 + (-0.002516 - 0.0000074 * t) * t;
}

/******************************************************************************!
 * \fn moonNorthernMaximumDeclinationD
 ******************************************************************************/
double
moonNorthernMaximumDeclinationD(double k, double t)
{
    return reduceAngle(152.2029 +
                       333.0705546 * k + (-0.0004025 + 0.00000011 * t) * t);
}

/******************************************************************************!
 * \fn moonNorthernMaximumDeclinationM
 ******************************************************************************/
double
moonNorthernMaximumDeclinationM(double k, double t)
{
    return reduceAngle(14.8591 +
                       26.9281592 * k + (-0.0000544 - 0.00000010 * t) * t * t);
}

/******************************************************************************!
 * \fn moonNorthernMaximumDeclinationMp
 ******************************************************************************/
double
moonNorthernMaximumDeclinationMp(double k, double t)
{
    return reduceAngle(4.6881 +
                       356.9562795 * k + (0.0103126 + 0.00001251 * t) * t * t);
}

/******************************************************************************!
 * \fn moonNorthernMaximumDeclinationF
 ******************************************************************************/
double
moonNorthernMaximumDeclinationF(double k, double t)
{
    return reduceAngle(325.8867 +
                       1.4467806 * k + (-0.0020708 - 0.00000215 * t) * t * t);
}

/******************************************************************************!
 * \fn moonNorthernMaximumDeclination
 ******************************************************************************/
double
moonNorthernMaximumDeclination(double k, double t, double D,
                               double M, double Mp, double F, double E)
{
    D *= M_PI / 180;
    M *= M_PI / 180;
    Mp *= M_PI / 180;
    F *= M_PI / 180;
    return
        2451562.5897 + 27.321582241 * k +
        (0.000100695 - 0.000000141 * t) * t * t +
        0.8975 * cos(F) +
        -0.4726 * sin(Mp) +
        -0.1030 * sin(2 * F) +
        -0.0976 * sin(2 * D - Mp) +
        -0.0462 * cos(Mp - F) +
        -0.0461 * cos(Mp + F) +
        -0.0438 * sin(2 * D) +
        0.0162 * sin(M) * E +
        -0.0157 * cos(3 * F) +
        0.0145 * sin(Mp + 2 * F) +
        0.0136 * cos(2 * D - F) +
        -0.0095 * cos(2 * D - Mp - F) +
        -0.0091 * cos(2 * D - Mp + F) +
        -0.0089 * cos(2 * D + F) +
        0.0075 * sin(2 * Mp) +
        -0.0068 * sin(Mp - 2 * F) +
        0.0061 * cos(2 * Mp - F) +
        -0.0047 * sin(Mp + 3 * F) +
        -0.0043 * sin(2 * D - M - Mp) * E +
        -0.0040 * cos(Mp - 2 * F) +
        -0.0037 * sin(2 * D - 2 * Mp) +
        0.0031 * sin(F) +
        0.0030 * sin(2 * D + Mp) +
        -0.0029 * cos(Mp + 2 * F) +
        -0.0029 * sin(2 * D - M) * E +
        -0.0027 * sin(Mp + F) +
        +0.0024 * sin(M - Mp) * E +
        -0.0021 * sin(Mp - 3 * F) +
        0.0019 * sin(2 * Mp + F) +
        0.0018 * cos(2 * D - 2 * Mp - F) +
        0.0018 * sin(3 * F) +
        0.0017 * cos(Mp + 3 * F) +
        0.0017 * cos(2 * Mp) +
        -0.0014 * cos(2 * D - Mp) +
        0.0013 * cos(2 * D + Mp + F) +
        0.0013 * cos(Mp) +
        0.0012 * sin(3 * Mp + F) +
        0.0011 * sin(2 * D - Mp + F) +
        -0.0011 * cos(2 * D - 2 * Mp) +
        0.0010 * cos(D + F) +
        0.0010 * sin(M + Mp) * E +
        -0.0009 * sin(2 * D - 2 * F) +
        0.0007 * cos(2 * Mp + F) +
        -0.0007 * cos(3 * Mp + F);
}

/******************************************************************************!
 * \fn moonSouthernMaximumDeclinationD
 ******************************************************************************/
double
moonSouthernMaximumDeclinationD(double k, double t)
{
    return reduceAngle(345.6676 +
                       333.0705546 * k + (-0.0004025 + 0.00000011 * t) * t);
}

/******************************************************************************!
 * \fn moonSouthernMaximumDeclinationM
 ******************************************************************************/
double
moonSouthernMaximumDeclinationM(double k, double t)
{
    return reduceAngle(1.3951 +
                       26.9281592 * k + (-0.0000544 - 0.00000010 * t) * t * t);
}

/******************************************************************************!
 * \fn moonSouthernMaximumDeclinationMp
 ******************************************************************************/
double
moonSouthernMaximumDeclinationMp(double k, double t)
{
    return reduceAngle(186.2100 +
                       356.9562795 * k + (0.0103126 + 0.00001251 * t) * t * t);
}

/******************************************************************************!
 * \fn moonSouthernMaximumDeclinationF
 ******************************************************************************/
double
moonSouthernMaximumDeclinationF(double k, double t)
{
    return reduceAngle(145.1633 +
                       1.4467806 * k + (-0.0020708 - 0.00000215 * t) * t * t);
}

/******************************************************************************!
 * \fn moonSouthernMaximumDeclination
 ******************************************************************************/
double
moonSouthernMaximumDeclination(double k, double t, double D,
                               double M, double Mp, double F, double E)
{
    D *= M_PI / 180;
    M *= M_PI / 180;
    Mp *= M_PI / 180;
    F *= M_PI / 180;
    return
        2451548.9289 + 27.321582241 * k +
        (0.000100695 - 0.000000141 * t) * t * t +
        -0.8975 * cos(F) +
        -0.4726 * sin(Mp) +
        -0.1030 * sin(2 * F) +
        -0.0976 * sin(2 * D - Mp) +
        0.0541 * cos(Mp - F) +
        0.0516 * cos(Mp + F) +
        -0.0438 * sin(2 * D) +
        0.0112 * sin(M) * E +
        0.0157 * cos(3 * F) +
        0.0023 * sin(Mp + 2 * F) +
        -0.0136 * cos(2 * D - F) +
        0.0110 * cos(2 * D - Mp - F) +
        0.0091 * cos(2 * D - Mp + F) +
        0.0089 * cos(2 * D + F) +
        0.0075 * sin(2 * Mp) +
        -0.0030 * sin(Mp - 2 * F) +
        -0.0061 * cos(2 * Mp - F) +
        -0.0047 * sin(Mp + 3 * F) +
        -0.0043 * sin(2 * D - M - Mp) * E +
        0.0040 * cos(Mp - 2 * F) +
        -0.0037 * sin(2 * D - 2 * Mp) +
        -0.0031 * sin(F) +
        0.0030 * sin(2 * D + Mp) +
        0.0029 * cos(Mp + 2 * F) +
        -0.0029 * sin(2 * D - M) * E +
        -0.0027 * sin(Mp + F) +
        +0.0024 * sin(M - Mp) * E +
        -0.0021 * sin(Mp - 3 * F) +
        -0.0019 * sin(2 * Mp + F) +
        -0.0006 * cos(2 * D - 2 * Mp - F) +
        -0.0018 * sin(3 * F) +
        -0.0017 * cos(Mp + 3 * F) +
        0.0017 * cos(2 * Mp) +
        0.0014 * cos(2 * D - Mp) +
        -0.0013 * cos(2 * D + Mp + F) +
        -0.0013 * cos(Mp) +
        0.0012 * sin(3 * Mp + F) +
        0.0011 * sin(2 * D - Mp + F) +
        0.0011 * cos(2 * D - 2 * Mp) +
        0.0010 * cos(D + F) +
        0.0010 * sin(M + Mp) * E +
        -0.0009 * sin(2 * D - 2 * F) +
        -0.0007 * cos(2 * Mp + F) +
        -0.0007 * cos(3 * Mp + F);
}

/******************************************************************************!
 * \fn yearWithDecimals
 ******************************************************************************/
double
yearWithDecimals(double year, double month, double day)
{
    return year + (month - 1) / 12.0 + (day - 1) / 365.25;
}

/******************************************************************************!
 * \fn moonApogeeOrPerigeeK
 * \note 1: (48.2) p325
 *       2: (50.2) p355
 ******************************************************************************/
double
moonApogeeOrPerigeeK(double year)
{
    return floor((year - 1999.97) * 13.2555);
}

/******************************************************************************!
 * \fn moonNodeK
 ******************************************************************************/
double
moonNodeK(double year)
{
    return floor((year - 2000.05) * 13.4223);
}

/******************************************************************************!
 * \fn moonMaximumDeclinationK
 ******************************************************************************/
double
moonMaximumDeclinationK(double year)
{
    return floor((year - 2000.03) * 13.3686);
}

/******************************************************************************!
 * \fn moonApogeeOrPerigeeT
 * \note 1: (48.3) p326
 *       2: (50.3) p356
 ******************************************************************************/
double
moonApogeeOrPerigeeT(double k)
{
    return k / 1325.55;
}

/******************************************************************************!
 * \fn moonNodeT
 ******************************************************************************/
double
moonNodeT(double k)
{
    return k / 1342.23;
}

/******************************************************************************!
 * \fn moonMaximumDeclinationT
 ******************************************************************************/
double
moonMaximumDeclinationT(double k)
{
    return k / 1336.86;
}
