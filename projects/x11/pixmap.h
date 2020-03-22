/******************************************************************************!
 * \file pixmap.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef _X11_PIXMAP_H_
#define _X11_PIXMAP_H_

#include "drawable.h"

typedef unsigned long ULong;

namespace X11 {

class Pixmap : public Drawable
{
public:
    Pixmap(Display* dpy, int w, int h);
    Pixmap(Display* dpy);
    ~Pixmap();
    void create();
    ::Pixmap id() { return mPixmap; }
    void setSize(int w, int h);
    void clear(ULong color);

private:
    ::Pixmap mPixmap;
};

}  // namespace X11

#endif
