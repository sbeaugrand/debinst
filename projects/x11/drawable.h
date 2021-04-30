/******************************************************************************!
 * \file drawable.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef _X11_DRAWABLE_H_
#define _X11_DRAWABLE_H_

#include <X11/Xlib.h>
#include <X11/Xutil.h>

namespace X11 {

class Display;

class Drawable
{
public:
    Drawable(Display* display, int w, int h);
    Drawable(Display* display, int x, int y, int w, int h);
    explicit Drawable(Display* display);
    virtual ~Drawable() { }

    virtual void setPosition(int x, int y);
    virtual void setSize(int w, int h);
    void getPosition(int* x, int* y);

    Display* getDisplay() { return mDisplay; }
    int getWidth() { return mIndic.width; }
    int getHeight() { return mIndic.height; }

    int contains(int x, int y);

private:
    void init(Display* display);

protected:
    Display* mDisplay;
    ::Display* mX11Display;
    GC mGC;
    XSizeHints mIndic;
};

}  // namespace X11

#endif
