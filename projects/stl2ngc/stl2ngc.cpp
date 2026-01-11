/******************************************************************************!
 * \file stl2ngc.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright GNU GNU GPLv3
 * \note Modified from :
 *       https://github.com/koppi/stl2ngc.git
 ******************************************************************************/
/*
 *  Copyright 2016-2023 Jakob Flierl (jakob.flierl "at" gmail.com)
 *
 *  stl2ngc is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  stl2ngc is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with stl2ngc.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <string>
#include <vector>
#include <iomanip>
#include <argp.h>

#include <opencamlib/stlsurf.hpp>
#include <opencamlib/stlreader.hpp>
#include <opencamlib/cylcutter.hpp>
#include <opencamlib/conecutter.hpp>
#include <opencamlib/adaptivepathdropcutter.hpp>

#ifdef _OPENMP
# include <omp.h>
#endif

using namespace std;
using namespace ocl;

/******************************************************************************!
 * argp
 ******************************************************************************/
const char* argp_program_version =
    "stl2ngc 1.0.0";
const char* argp_program_bug_address =
    "<sbeaugrand@toto.fr>";
static char doc[] =
    "stl2ngc -- "
    "convert a STL file to LinuxCNC compatible G-code";
static struct argp_option options[] = {
    { "diameter", 'd', "F", 0, "[default: 2 (mm)]", 0 },
    { "length", 'l', "F", 0, "[default: 6 (mm)]", 0 },
    { "angle", 'a', "F", 0, "ConeCutter angle [default: 0 (CylCutter)]", 0 },
    { "zigzag", 'z', "x|y", 0, "[default: x]", 0 },
    {}
};
struct arguments
{
    double diameter = 2;
    double length = 6;
    double angle = 0;
    bool zigzag_x = true;
};
static error_t
parse_opt(int key, char* arg, struct argp_state* state)
{
    struct arguments* arguments = static_cast<struct arguments*>(state->input);
    switch (key) {
    case 'd':
        arguments->diameter = ::atof(arg);
        break;
    case 'l':
        arguments->length = ::atof(arg);
        break;
    case 'a':
        arguments->angle = ::atof(arg);
        break;
    case 'z':
        if (*arg == 'y') {
            arguments->zigzag_x = false;
        }
        break;
    default:
        return ARGP_ERR_UNKNOWN;
    }
    return 0;
}
static struct argp argp = { options, parse_opt, 0, doc, 0, 0, 0 };

/******************************************************************************!
 * \fn wstr
 ******************************************************************************/
wstring
wstr(const char* str)
{
    wstring wstr(str, str + ::strlen(str));
    return wstr;
}

/******************************************************************************!
 * \class APDC
 ******************************************************************************/
class APDC : public AdaptivePathDropCutter
{
public:
    APDC() : AdaptivePathDropCutter() {}
    virtual ~APDC() {}
    vector<CLPoint> getPoints() {
        return clpoints;
    }
};

/******************************************************************************!
 * \class GCodeWriter
 ******************************************************************************/
class GCodeWriter
{
public:
    GCodeWriter() {};
    virtual ~GCodeWriter() {};
    void g1(const double x, const double y, const double z) {
        cout << "G1 X" << x << " Y" << y << " Z" << z << endl;
    }
    void g0(const double x,
            const double y,
            const double z) {
        cout << "G0 X" << x << " Y" << y << " Z" << z << endl;
    }
};

/******************************************************************************!
 * \fn zigzag_x
 ******************************************************************************/
Path
zigzag_x(double minx, double /*dx*/, double maxx,
         double miny, double dy, double maxy, double z)
{
    Path p;

    int rev = 0;
    for (double i = miny; i < maxy; i += dy) {
        if (rev == 0) {
            p.append(Line(Point(minx, i, z), Point(maxx, i, z)));
            rev = 1;
        } else {
            p.append(Line(Point(maxx, i, z), Point(minx, i, z)));
            rev = 0;
        }
    }

    return p;
}

/******************************************************************************!
 * \fn zigzag_y
 ******************************************************************************/
Path
zigzag_y(double minx, double dx, double maxx,
         double miny, double /*dy*/, double maxy, double z)
{
    Path p;

    int rev = 0;
    for (double i = minx; i < maxx; i += dx) {
        if (rev == 0) {
            p.append(Line(Point(i, miny, z), Point(i, maxy, z)));
            rev = 1;
        } else {
            p.append(Line(Point(i, maxy, z), Point(i, miny, z)));
            rev = 0;
        }
    }

    return p;
}

/******************************************************************************!
 * \fn isNearlyEqual
 ******************************************************************************/
bool
isNearlyEqual(double a, double b)
{
    int factor = 0.00001;

    double min_a = a -
        (a - std::nextafter(a, std::numeric_limits<double>::lowest())) * factor;
    double max_a = a +
        (std::nextafter(a, std::numeric_limits<double>::max()) - a) * factor;

    return min_a <= b && max_a >= b;
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char* argv[])
{
    struct arguments arguments = {};
    ::argp_parse(&argp, argc, argv, 0, 0, &arguments);

    double zsafe = 5;
    double zstep = 3;

    cerr << "stl2ngc  Copyright (C) 2016 - 2023 Jakob Flierl" << endl;
    cerr << "This program comes with ABSOLUTELY NO WARRANTY;" << endl;
    cerr << "This is free software, and you are welcome to redistribute it"
        " under certain conditions." << endl << endl;

    cout.setf(ios::fixed, ios::floatfield);
    cout.setf(ios::showpoint);

    cerr.setf(ios::fixed, ios::floatfield);
    cerr.setf(ios::showpoint);

    double d_cutter = arguments.diameter;
    double l_cutter = arguments.length;
    MillingCutter* c;
    if (arguments.angle > 0) {
        double a_cutter = arguments.angle * PI / 180;
        c = new ConeCutter(d_cutter, a_cutter / 2, l_cutter);
        cerr << *static_cast<ConeCutter*>(c) << endl;
    } else {
        c = new CylCutter(d_cutter, l_cutter);
        cerr << *static_cast<CylCutter*>(c) << endl;
    }
    double d_overlap = d_cutter * (1 - 0.75);  // step percentage
    double corner = 0;  // d_cutter

    STLSurf s;
    STLReader r(wstr("/dev/stdin"), s);
    cerr << s << endl;
    cerr << s.bb << endl;

    double zdim = s.bb.maxpt.z - s.bb.minpt.z;
    cerr << "zdim " << zdim << endl;

    double zstart = s.bb.maxpt.z - zstep;
    cerr << "zstart " << zstart << endl;

    APDC apdc;
    apdc.setSTL(s);
    apdc.setCutter(c);
    apdc.setSampling(d_overlap);
    apdc.setMinSampling(d_overlap / 100);

    double minx, miny, maxx, maxy, z;
    minx = s.bb.minpt.x - corner;
    miny = s.bb.minpt.y - corner;
    maxx = s.bb.maxpt.x + corner;
    maxy = s.bb.maxpt.y + corner;
    z = s.bb.minpt.z - zsafe;

    double dx = d_overlap, dy = d_overlap;

    Path p;
    if (arguments.zigzag_x) {
        p = zigzag_x(minx, dx, maxx, miny, dy, maxy, z);
    } else {
        p = zigzag_y(minx, dx, maxx, miny, dy, maxy, z);
    }
    apdc.setPath(&p);
    apdc.setZ(z);

    cerr << "calculating... ";

    apdc.setThreads(4);
    apdc.run();

    cerr << "done." << endl;

    GCodeWriter w;

    cout << "G21 F900" << endl;
    cout << "G64 P0.001" << endl;  // path control mode : constant velocity
    cout << "M03 S13500" << endl;  // start spindle

    cout << "G0" <<
        " X" << s.bb.minpt.x <<
        " Y" << s.bb.minpt.y <<
        " Z" << zsafe << endl;

    double zcurr = zstart;

    vector<CLPoint> pts = apdc.getPoints();

    bool fst = true;
    while (zcurr > s.bb.minpt.z - zstep) {

        cerr << "zcurr " << zcurr << endl;

        BOOST_FOREACH(Point cp, pts) {
            if (cp.z < s.bb.minpt.z) {
                z = 1;
            } else {
                z = -fmin(-cp.z, -zcurr) - s.bb.maxpt.z;
            }
            //if (!isNearlyEqual(z, 0)) {
            if (fst) {
                w.g0(cp.x, cp.y, zsafe);
                w.g0(cp.x, cp.y, 0);
                fst = false;
            }
            w.g1(cp.x, cp.y, z);
            //}
        }

        zcurr -= zstep;
        reverse(pts.begin(), pts.end());
    }

    cout << "G0Z" << zsafe << endl;
    cout << "M05" << endl;  // stop spindle
    cout << "G0"
         << " X" << s.bb.minpt.x
         << " Y" << s.bb.minpt.y << endl;
    cout << "M2" << endl;
    cout << "%" << endl;

    return 0;
}
