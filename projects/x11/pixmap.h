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
    explicit Pixmap(Display* dpy);
    ~Pixmap() override;
    void create();
    ::Pixmap id() { return mPixmap; }
    void setSize(int w, int h) override;
    void clear(ULong color);

private:
    ::Pixmap mPixmap;
};

}  // namespace X11

#endif
