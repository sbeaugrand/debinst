/******************************************************************************!
 * \file drawable.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include "drawable.h"
#include "display.h"

namespace X11 {

/******************************************************************************!
 * \fn Drawable
 ******************************************************************************/
Drawable::Drawable(Display* display, int w, int h)
{
    init(display);
    Drawable::setSize(w, h);
}

/******************************************************************************!
 * \fn Drawable
 ******************************************************************************/
Drawable::Drawable(Display* display, int x, int y, int w, int h)
{
    init(display);
    Drawable::setPosition(x, y);
    Drawable::setSize(w, h);
}

/******************************************************************************!
 * \fn Drawable
 ******************************************************************************/
Drawable::Drawable(Display* display)
{
    init(display);
}

/******************************************************************************!
 * \fn init
 ******************************************************************************/
void Drawable::init(Display* display)
{
    mDisplay = display;
    mX11Display = mDisplay->id();
    mGC = mDisplay->gc();
    mIndic.flags = 0;
    Drawable::setPosition(1, 1);
}

/******************************************************************************!
 * \fn getPosition
 ******************************************************************************/
void Drawable::getPosition(int* x, int* y)
{
    *x = mIndic.x;
    *y = mIndic.y;
}

/******************************************************************************!
 * \fn setPosition
 ******************************************************************************/
void Drawable::setPosition(int x, int y)
{
    mIndic.x = x;
    mIndic.y = y;
    mIndic.flags |= PPosition;
}

/******************************************************************************!
 * \fn setSize
 ******************************************************************************/
void Drawable::setSize(int w, int h)
{
    mIndic.width = w;
    mIndic.height = h;
    mIndic.flags |= PSize;
}

/******************************************************************************!
 * \fn contains
 ******************************************************************************/
int Drawable::contains(int x, int y)
{
    return x >= mIndic.x &&
           x < mIndic.x + mIndic.width &&
           y >= mIndic.y &&
           y < mIndic.y + mIndic.height;
}

}  // namespace X11
