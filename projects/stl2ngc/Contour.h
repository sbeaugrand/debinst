/******************************************************************************!
 * \file Contour.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright GNU GNU GPLv3
 ******************************************************************************/
#ifndef CONTOUR_H
#define CONTOUR_H

#include <vector>
#include <cmath>

#include <opencamlib/stlsurf.hpp>
#include <opencamlib/millingcutter.hpp>
#include <opencamlib/pointdropcutter.hpp>

/******************************************************************************!
 * \class Contour
 * \brief Paths following the steps detected in the zigzag (positions where
 *        the tool goes up or down), to remove the scallops left on the walls.
 ******************************************************************************/
class Contour
{
public:
    Contour(const ocl::STLSurf& s, const ocl::MillingCutter* c, bool zigzag_x,
            double origin, double step, double minSampling)
        : zinit(s.bb.minpt.z - 1), zmin(s.bb.minpt.z),
          radius(c->getDiameter() / 2), origin(origin), step(step),
          minSampling(minSampling),
          axis(zigzag_x ? ocl::Point(1, 0, 0) : ocl::Point(0, 1, 0)),
          zigzag_x(zigzag_x) {
        pdc.setSTL(s);
        pdc.setCutter(c);
    }
    virtual ~Contour() {}
    std::vector<std::vector<ocl::Point> >
    run(const std::vector<ocl::CLPoint>& pts);
    std::vector<std::vector<ocl::Point> >
    order(std::vector<std::vector<ocl::Point> > chains, ocl::Point curr);
private:
    struct Edge {
        ocl::Point p;  // low side of the step
        long line;
        int dir;  // direction of the high side along the line
    };
    struct Link {
        size_t i;
        size_t j;
        std::vector<ocl::Point> pts;  // from i (excluded) to j (included)
    };
    const double ZEPS = 0.005;
    const double ZSTEP = 0.1;
    const int DEPTH = 16;
    double zAt(const ocl::Point& p) {
        ocl::CLPoint cl(p.x, p.y, zinit);
        pdc.run(cl);
        return cl.z;
    }
    bool isLow(const ocl::Point& p, double z) {
        return fabs(zAt(p) - z) < ZEPS;
    }
    ocl::Point bisect(ocl::Point low, ocl::Point high, double z);
    bool refine(const ocl::Point& a, const ocl::Point& b, ocl::Point v,
                std::vector<ocl::Point>& out, int depth);
    long line(const ocl::Point& p) {
        return lround(((zigzag_x ? p.y : p.x) - origin) / step);
    }
    ocl::PointDropCutter pdc;
    double zinit;
    double zmin;
    double radius;
    double origin;
    double step;
    double minSampling;
    ocl::Point axis;
    bool zigzag_x;
};

#endif
