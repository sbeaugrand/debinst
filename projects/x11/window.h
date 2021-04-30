/******************************************************************************!
 * \file window.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef _X11mWINDOW_H_
#define _X11mWINDOW_H_

#include <list>
#include "drawable.h"

typedef unsigned long ULong;

namespace X11 {

class Display;
class Pixmap;

class Window : public Drawable
{
public:
    Window(Display* display, int w, int h);
    explicit Window(Display* display);
    Window(Window* parent, int x, int y, int w, int h);
    explicit Window(Window* parent);
    virtual ~Window();
    virtual void setSize(int w, int h);
    virtual void raise(ULong color);
    Window* getParent() { return mParent; }
    ::Window id() { return mWindow; }
    ::Pixmap getPixmap() { return mX11Pixmap; }
    void clear(ULong color);
    void addChild(Window* w) { mChilds->push_back(w); }
    void create(ULong color);
    void setPosition(int x, int y);
    void setTitle(const char* title);
    void addInput(ULong mask);
    void delInput(ULong mask);
    void delInput();
    void refresh();
    void refresh(int x1, int y1, int x2, int y2);
    void refreshAll();
    void flush();
    void destroy();
    int parentIsRoot() { return ! mParent; }

    void drawPoint(int x, int y) {
        XDrawPoint(mX11Display, mX11Pixmap, mGC, x, y);
    }
    void drawLine(int xo, int yo, int xs, int ys) {
        XDrawLine(mX11Display, mX11Pixmap, mGC, xo, yo, xs, ys);
    }
    void drawLines(XPoint* points, int npoints, int mode) {
        XDrawLines(mX11Display, mX11Pixmap, mGC, points, npoints, mode);
    }
    void drawRectangle(int x, int y, int w, int h) {
        XDrawRectangle(mX11Display, mX11Pixmap, mGC, x, y, w, h);
    }
    void fillRectangle(int x, int y, int w, int h) {
        XFillRectangle(mX11Display, mX11Pixmap, mGC, x, y, w, h);
    }
    void fillPolygon(XPoint* p, int n, int shape, int mode) {
        XFillPolygon(mX11Display, mX11Pixmap, mGC, p, n, shape, mode);
    }
    void drawBox(int xo, int yo, int xs, int ys) {
        XDrawRectangle(mX11Display, mX11Pixmap, mGC,
                       xo, yo, xs - xo + 1, ys - yo + 1);
    }
    void drawString(int x, int y, const char* s, int n) {
        XDrawString(mX11Display, mX11Pixmap, mGC, x, y, s, n);
    }
    friend int operator==(const Window& w1, const Window& w2);
    friend int operator!=(const Window& w1, const Window& w2);

protected:
    void init(Window* parent);

protected:
    ::Window mWindow;
    Window* mParent;
    Pixmap* mPixmap;
    ::Pixmap mX11Pixmap;
    ULong mEventMask;
    char mTitle[80];
    std::list<Window*>* mChilds;
};

}  // namespace X11

#endif
