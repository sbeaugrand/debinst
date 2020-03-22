/******************************************************************************!
 * \file pixmap.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include "pixmap.h"
#include "display.h"

namespace X11 {

/******************************************************************************!
 * \fn Pixmap
 ******************************************************************************/
Pixmap::Pixmap(Display* display, int w, int h)
    : Drawable(display, w, h)
{
    create();
}

/******************************************************************************!
 * \fn Pixmap
 ******************************************************************************/
Pixmap::Pixmap(Display* display)
    : Drawable(display)
{
    create();
}

/******************************************************************************!
 * \fn create
 ******************************************************************************/
void Pixmap::create()
{
    mPixmap =
        XCreatePixmap(mX11Display, mDisplay->root(),
                      mIndic.width, mIndic.height, mDisplay->depth());
}

/******************************************************************************!
 * \fn ~Pixmap
 ******************************************************************************/
Pixmap::~Pixmap()
{
    XFreePixmap(mX11Display, mPixmap);
}

/******************************************************************************!
 * \fn setSize
 ******************************************************************************/
void Pixmap::setSize(int w, int h)
{
    ::Pixmap save = mPixmap;
    int width = mIndic.width;
    int height = mIndic.height;

    Drawable::setSize(w, h);
    create();
    XCopyArea(mX11Display, save, mPixmap, mGC, 0, 0, width, height, 0, 0);
    XFreePixmap(mX11Display, save);
}

/******************************************************************************!
 * \fn clear
 ******************************************************************************/
void Pixmap::clear(ULong color)
{
    XSetForeground(mX11Display, mGC, color);
    XFillRectangle(mX11Display, mPixmap, mGC,
                   0, 0, mIndic.width, mIndic.height);
}

}  // namespace X11
