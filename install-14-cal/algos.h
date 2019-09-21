/******************************************************************************!
 * \file algos.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note Source: Astronomical algorithms - Jean Meeus - 1991
 ******************************************************************************/
#define DEG(a) (a) * 180 / M_PI
#define RAD(a) (a) * M_PI / 180
#define COS(a) cos(RAD(a))
#define SIN(a) sin(RAD(a))
#define TAN(a) tan(RAD(a))

double
deg(double deg, double min, double sec);
double
reduceAngle(double a);
double
julianDay(int Y, int M, double D);
double
julianTime(double jd);
double
sunGeometricMeanLongitude(double t);
double
sunMeanAnomaly(double t);
double
earthOrbitEccentricity(double t);
double
sunCenterEquation(double t, double M);
double
sunTrueLongitude(double L, double C);
double
sunTrueAnomaly(double M, double C);
double
sunRadius(double e, double nu);
double
sunApparentLongitude(double t, double theta);
double
eclipticObliquity(double t);
double
eclipticObliquityCorrected(double t, double eps);
double
sunApparentRightAscension(double eps, double theta);
double
sunApparentDeclination(double eps, double theta);
void
nutation(double t, double* nutationInLongitude, double* nutationInObliquity);
double
sideralTime(double jd, double t);
double
apparentSideralTime(double theta0, double nutationInLongitude, double eps);
double
altitude(double ra, double dec, double theta0, double lat, double lon);
double
equationOfTime(double L, double ra, double nutationInLongitude, double eps);
double
gmtOffset(int year, int month, int day);
void
sunApparentRightAscensionAndDeclination(double jd, double* ra, double* dec,
                                        double* nutationInLongitude,
                                        double* eps);
void
jde2date(double jde, int* YY, int* MM, int* DD, int* hh, int* mm);
double
moonJulianEphemerisDay(double k, double t);
double
moonMeanElongation(double k, double t);
double
moonSunMeanAnomaly(double k, double t);
double
moonArgumentOfLatitude(double k, double t);
double
moonApogee(double t, double D, double M, double F);
double
moonPerigee(double t, double D, double M, double F);
double
moonNodeD(double k, double t);
double
moonNodeM(double k, double t);
double
moonNodeMp(double k, double t);
double
moonNodeOmega(double k, double t);
double
moonNodeV(double t);
double
moonNodeP(double omega, double t);
double
moonNodeE(double t);
double
moonNode(double k, double t, double D,
         double M, double Mp, double omega, double V, double P, double E);
double
moonMaximumDeclinationE(double t);
double
moonNorthernMaximumDeclinationD(double k, double t);
double
moonNorthernMaximumDeclinationM(double k, double t);
double
moonNorthernMaximumDeclinationMp(double k, double t);
double
moonNorthernMaximumDeclinationF(double k, double t);
double
moonNorthernMaximumDeclination(double k, double t, double D,
                               double M, double Mp, double F, double E);
double
moonSouthernMaximumDeclinationD(double k, double t);
double
moonSouthernMaximumDeclinationM(double k, double t);
double
moonSouthernMaximumDeclinationMp(double k, double t);
double
moonSouthernMaximumDeclinationF(double k, double t);
double
moonSouthernMaximumDeclination(double k, double t, double D,
                               double M, double Mp, double F, double E);
double
yearWithDecimals(double year, double month, double day);
double
moonApogeeOrPerigeeK(double year);
double
moonNodeK(double year);
double
moonMaximumDeclinationK(double year);
double
moonApogeeOrPerigeeT(double k);
double
moonNodeT(double k);
double
moonMaximumDeclinationT(double k);
