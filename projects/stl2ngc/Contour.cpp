/******************************************************************************!
 * \file Contour.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright GNU GNU GPLv3
 ******************************************************************************/
#include <iostream>
#include <algorithm>

#include "Contour.h"

using namespace std;
using namespace ocl;

/******************************************************************************!
 * \fn bisect
 ******************************************************************************/
Point
Contour::bisect(Point low, Point high, double z)
{
    for (int k = 0; k < 20; ++k) {
        Point m = (low + high) * 0.5;
        if (isLow(m, z)) {
            low = m;
        } else {
            high = m;
        }
    }
    low.z = z;
    return low;
}

/******************************************************************************!
 * \fn refine
 * \brief Subdivide [a, b] with points at the boundary of the low area.
 *        v is the side of the high area (null if unknown).
 ******************************************************************************/
bool
Contour::refine(const Point& a, const Point& b, Point v, vector<Point>& out,
                int depth)
{
    Point ab = b - a;
    double l = ab.xyNorm();
    if (l <= step / 4) {
        out.push_back(b);
        return true;
    }
    if (depth == 0) {
        return false;
    }
    Point m = (a + b) * 0.5;
    Point n(-ab.y / l, ab.x / l, 0);
    double t = fmin(l, radius);
    bool low = isLow(m, a.z);
    bool found = false;
    Point best;
    for (int k = 0; k < 2; ++k) {
        Point d = (k == 0) ? n : n * -1;
        if (v.xyNorm() > 0 && d.dot(v) <= 0) {
            continue;
        }
        Point p;
        if (low) {
            if (isLow(m + d * t, a.z)) {
                continue;
            }
            p = bisect(m, m + d * t, a.z);
        } else {
            if (! isLow(m - d * t, a.z)) {
                continue;
            }
            p = bisect(m - d * t, m, a.z);
        }
        if (! found || (p - m).xyNorm() < (best - m).xyNorm()) {
            best = p;
            v = d;
            found = true;
        }
    }
    if (! found) {
        return false;
    }
    return refine(a, best, v, out, depth - 1) &&
        refine(best, b, v, out, depth - 1);
}

/******************************************************************************!
 * \fn run
 ******************************************************************************/
vector<vector<Point> >
Contour::run(const vector<CLPoint>& pts)
{
    // Steps
    vector<Edge> edges;
    for (size_t k = 1; k < pts.size(); ++k) {
        const CLPoint& a = pts[k - 1];
        const CLPoint& b = pts[k];
        if (a.z < zmin || b.z < zmin || fabs(a.z - b.z) < ZSTEP ||
            line(a) != line(b) || (b - a).xyNorm() > 2 * minSampling) {
            continue;
        }
        Point low = (a.z < b.z) ? a : b;
        Point high = (a.z < b.z) ? b : a;
        Edge e;
        e.p = bisect(low, high, low.z);
        e.line = line(low);
        e.dir = ((high - low).dot(axis) > 0) ? 1 : -1;
        edges.push_back(e);
    }
    cerr << "contour edges " << edges.size() << endl;

    // Candidate links, shortest first
    vector<pair<double, pair<size_t, size_t> > > cand;
    for (size_t i = 0; i < edges.size(); ++i) {
        for (size_t j = i + 1; j < edges.size(); ++j) {
            const Edge& a = edges[i];
            const Edge& b = edges[j];
            if (fabs(a.p.z - b.p.z) > ZEPS) {
                continue;
            }
            double d = (b.p - a.p).xyNorm();
            long dl = labs(a.line - b.line);
            if ((dl == 1 && a.dir == b.dir && d <= 8 * step) ||
                (dl == 0 && a.dir != b.dir && d <= 2 * radius)) {
                cand.push_back(make_pair(d, make_pair(i, j)));
            }
        }
    }
    sort(cand.begin(), cand.end());

    vector<Link> links;
    vector<vector<size_t> > adj(edges.size());
    for (auto& c : cand) {
        size_t i = c.second.first;
        size_t j = c.second.second;
        if (adj[i].size() >= 2 || adj[j].size() >= 2) {
            continue;
        }
        Point v;  // unknown side if on the same line
        if (edges[i].line != edges[j].line) {
            v = axis * edges[i].dir;
        }
        Link link;
        link.i = i;
        link.j = j;
        if (! refine(edges[i].p, edges[j].p, v, link.pts, DEPTH)) {
            continue;
        }
        adj[i].push_back(links.size());
        adj[j].push_back(links.size());
        links.push_back(link);
    }
    cerr << "contour links " << links.size() << endl;

    // Chains, open ones first, oriented for climb milling (M03: the
    // material on the right side of the tool)
    vector<vector<Point> > chains;
    vector<bool> used(links.size(), false);
    for (int pass = 0; pass < 2; ++pass) {
        for (size_t s = 0; s < edges.size(); ++s) {
            if (adj[s].empty() || (pass == 0 && adj[s].size() != 1)) {
                continue;
            }
            vector<Point> chain;
            vector<pair<size_t, size_t> > nodes;  // (index in chain, edge)
            chain.push_back(edges[s].p);
            nodes.push_back(make_pair(0, s));
            size_t n = s;
            for (;;) {
                size_t k = 0;
                while (k < adj[n].size() && used[adj[n][k]]) {
                    ++k;
                }
                if (k == adj[n].size()) {
                    break;
                }
                Link& link = links[adj[n][k]];
                used[adj[n][k]] = true;
                if (link.i == n) {
                    chain.insert(chain.end(), link.pts.begin(), link.pts.end());
                    n = link.j;
                } else {
                    chain.insert(chain.end(), link.pts.rbegin() + 1,
                                 link.pts.rend());
                    chain.push_back(edges[link.i].p);
                    n = link.i;
                }
                nodes.push_back(make_pair(chain.size() - 1, n));
            }
            if (chain.size() < 2) {
                continue;
            }
            double side = 0;
            for (auto& node : nodes) {
                size_t k = node.first;
                Point t = chain[min(k + 1, chain.size() - 1)] -
                    chain[k > 0 ? k - 1 : 0];
                Point right(t.y, -t.x, 0);
                side += right.dot(axis * edges[node.second].dir);
            }
            if (side < 0) {
                reverse(chain.begin(), chain.end());
            }
            chains.push_back(chain);
        }
    }
    cerr << "contour chains " << chains.size() << endl;
    return chains;
}

/******************************************************************************!
 * \fn order
 * \brief Order the chains from curr, each one starting at the nearest chain
 *        start (the direction is imposed), any point of a closed chain.
 ******************************************************************************/
vector<vector<Point> >
Contour::order(vector<vector<Point> > chains, Point curr)
{
    vector<vector<Point> > ordered;
    while (! chains.empty()) {
        size_t best = 0;
        size_t start = 0;
        double dbest = -1;
        for (size_t k = 0; k < chains.size(); ++k) {
            bool closed = (chains[k].back() - chains[k].front()).xyNorm() <
                1e-6;
            size_t n = closed ? chains[k].size() - 1 : 1;
            for (size_t i = 0; i < n; ++i) {
                double d = (chains[k][i] - curr).xyNorm();
                if (dbest < 0 || d < dbest) {
                    best = k;
                    start = i;
                    dbest = d;
                }
            }
        }
        vector<Point> chain = chains[best];
        chains.erase(chains.begin() + best);
        if (start > 0) {
            chain.pop_back();
            rotate(chain.begin(), chain.begin() + start, chain.end());
            chain.push_back(chain.front());
        }
        curr = chain.back();
        ordered.push_back(chain);
    }
    return ordered;
}
